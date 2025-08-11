class FigureImportService
  def initialize(file, current_user)
    @file = file
    @current_user = current_user
  end

  def call
    return validation_error unless valid_file?
    
    begin
      import_result = process_csv_file
      {
        success: true,
        message: "Successfully imported #{import_result[:created]} figures. #{import_result[:skipped]} duplicates skipped."
      }
    rescue StandardError => e
      {
        success: false,
        message: "Import failed: #{e.message}"
      }
    end
  end

  private

  def valid_file?
    @file.present? && @file.respond_to?(:path) && File.extname(@file.original_filename).downcase == '.csv'
  end

  def validation_error
    {
      success: false,
      message: 'Please select a valid CSV file.'
    }
  end

  def process_csv_file
    require 'csv'
    
    created_count = 0
    skipped_count = 0
    
    CSV.foreach(@file.path, headers: true, header_converters: :symbol) do |row|
      result = create_figure_from_row(row)
      
      if result[:created]
        created_count += 1
      else
        skipped_count += 1
      end
    end
    
    {
      created: created_count,
      skipped: skipped_count
    }
  end

  def create_figure_from_row(row)
    # Expected CSV columns: figure_number, name, dance_style_name, dance_level_name, measures, components, is_core
    dance_style = find_or_create_dance_style(row[:dance_style_name])
    dance_level = find_or_create_dance_level(row[:dance_level_name])
    
    # Check if figure already exists
    existing_figure = Figure.find_by(
      figure_number: row[:figure_number],
      dance_style: dance_style,
      dance_level: dance_level
    )
    
    return { created: false } if existing_figure
    
    figure = Figure.create!(
      figure_number: row[:figure_number],
      name: row[:name],
      dance_style: dance_style,
      dance_level: dance_level,
      measures: row[:measures]&.to_i,
      components: row[:components],
      is_core: row[:is_core]&.downcase == 'true'
    )
    
    { created: true, figure: figure }
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create figure from CSV row: #{e.message}"
    { created: false }
  end

  def find_or_create_dance_style(name)
    return nil if name.blank?
    
    DanceStyle.find_or_create_by(name: name.strip)
  end

  def find_or_create_dance_level(name)
    return nil if name.blank?
    
    # Try to extract level number from name (e.g., "Bronze 1" -> 1)
    level_number = name.scan(/\d+/).first&.to_i || 1
    
    DanceLevel.find_or_create_by(name: name.strip) do |level|
      level.level_number = level_number
    end
  end
end
