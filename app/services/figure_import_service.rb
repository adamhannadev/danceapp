class FigureImportService
  def initialize(file, current_user)
    @file = file
    @current_user = current_user
    @errors = []
    @warnings = []
  end

  def call
    return validation_error unless valid_file?
    
    begin
      import_result = process_csv_file
      {
        success: true,
        message: build_success_message(import_result),
        details: {
          created: import_result[:created],
          skipped: import_result[:skipped],
          errors: @errors,
          warnings: @warnings
        }
      }
    rescue StandardError => e
      Rails.logger.error "Figure import failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      {
        success: false,
        message: "Import failed: #{e.message}",
        details: { errors: @errors, warnings: @warnings }
      }
    end
  end

  private

  def valid_file?
    return false unless @file.present? && @file.respond_to?(:path)
    
    extension = File.extname(@file.original_filename).downcase
    size = @file.size
    
    return false unless extension == '.csv'
    return false if size > 10.megabytes
    
    true
  end

  def validation_error
    message = if @file.blank?
      'Please select a file to upload.'
    elsif !@file.respond_to?(:path)
      'Invalid file format.'
    elsif File.extname(@file.original_filename).downcase != '.csv'
      'Please select a valid CSV file.'
    elsif @file.size > 10.megabytes
      'File size must be less than 10MB.'
    else
      'Please select a valid CSV file.'
    end
    
    {
      success: false,
      message: message
    }
  end

  def process_csv_file
    require 'csv'
    
    created_count = 0
    skipped_count = 0
    row_number = 1  # Start at 1 for header
    
    CSV.foreach(@file.path, headers: true, header_converters: :symbol) do |row|
      row_number += 1
      
      begin
        result = create_figure_from_row(row, row_number)
        
        if result[:created]
          created_count += 1
        else
          skipped_count += 1
        end
        
      rescue StandardError => e
        @errors << "Row #{row_number}: #{e.message}"
        skipped_count += 1
      end
    end
    
    {
      created: created_count,
      skipped: skipped_count,
      total_rows: row_number - 1  # Subtract header row
    }
  end

  def create_figure_from_row(row, row_number)
    # Validate required fields
    validate_required_fields(row, row_number)
    
    # Find or create dance style and level
    dance_style = find_or_create_dance_style(row[:dance_style_name])
    dance_level = find_or_create_dance_level(row[:dance_level_name])
    
    # Check if figure already exists
    existing_figure = Figure.find_by(
      figure_number: row[:figure_number]&.to_s&.strip,
      dance_style: dance_style,
      dance_level: dance_level
    )
    
    if existing_figure
      @warnings << "Row #{row_number}: Figure '#{row[:figure_number]}' already exists for #{dance_style.name} #{dance_level.name}"
      return { created: false }
    end
    
    # Create the figure
    figure_attributes = build_figure_attributes(row, dance_style, dance_level)
    figure = Figure.create!(figure_attributes)
    
    { created: true, figure: figure }
    
  rescue ActiveRecord::RecordInvalid => e
    error_messages = e.record.errors.full_messages.join(', ')
    @errors << "Row #{row_number}: #{error_messages}"
    { created: false }
  end

  def validate_required_fields(row, row_number)
    required_fields = [:figure_number, :name, :dance_style_name, :dance_level_name, :measures]
    missing_fields = []
    
    required_fields.each do |field|
      if row[field].blank?
        missing_fields << field.to_s.humanize
      end
    end
    
    unless missing_fields.empty?
      raise "Missing required fields: #{missing_fields.join(', ')}"
    end
    
    # Validate measures is numeric
    unless row[:measures].to_s.match?(/^\d+$/)
      raise "Measures must be a positive number, got '#{row[:measures]}'"
    end
  end

  def build_figure_attributes(row, dance_style, dance_level)
    attributes = {
      figure_number: row[:figure_number]&.to_s&.strip,
      name: row[:name]&.to_s&.strip,
      dance_style: dance_style,
      dance_level: dance_level,
      measures: row[:measures].to_i,
      components: row[:components]&.to_s&.strip,
      is_core: parse_boolean(row[:is_core])
    }
    
    # Add video URL if provided
    if row[:video].present?
      video_url = row[:video].to_s.strip
      if valid_youtube_url?(video_url)
        attributes[:video] = video_url
      else
        @warnings << "Invalid YouTube URL format: #{video_url}"
      end
    end
    
    attributes
  end

  def parse_boolean(value)
    return false if value.blank?
    
    value_str = value.to_s.downcase.strip
    ['true', 't', 'yes', 'y', '1'].include?(value_str)
  end

  def valid_youtube_url?(url)
    return false if url.blank?
    
    youtube_regex = /\A(https?:\/\/)?(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)[\w-]+(&[\w=]*)*\z/i
    url.match?(youtube_regex)
  end

  def find_or_create_dance_style(name)
    return nil if name.blank?
    
    style_name = name.to_s.strip.titleize
    DanceStyle.find_or_create_by(name: style_name)
  end

  def find_or_create_dance_level(name)
    return nil if name.blank?
    
    level_name = name.to_s.strip.titleize
    
    # Try to extract level number from name (e.g., "Bronze 1" -> 1, "Silver" -> 2)
    level_number = case level_name.downcase
                   when /bronze/
                     1
                   when /silver/
                     2
                   when /gold/
                     3
                   when /open|championship/
                     4
                   else
                     level_name.scan(/\d+/).first&.to_i || 1
                   end
    
    DanceLevel.find_or_create_by(name: level_name) do |level|
      level.level_number = level_number
    end
  end

  def build_success_message(import_result)
    message_parts = []
    
    if import_result[:created] > 0
      message_parts << "Successfully imported #{import_result[:created]} figure(s)"
    end
    
    if import_result[:skipped] > 0
      message_parts << "#{import_result[:skipped]} duplicate(s) skipped"
    end
    
    if @warnings.any?
      message_parts << "#{@warnings.count} warning(s)"
    end
    
    if @errors.any?
      message_parts << "#{@errors.count} error(s)"
    end
    
    message_parts.join('. ') + '.'
  end
end
