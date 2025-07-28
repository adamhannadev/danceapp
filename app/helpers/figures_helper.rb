module FiguresHelper
  def dance_level_badge_class(dance_level)
    return 'bg-secondary' unless dance_level.respond_to?(:name)
    
    level_name = dance_level.name.downcase
    
    case level_name
    when 'bronze 1'
      'dance-level-bronze-1'
    when 'bronze 2'
      'dance-level-bronze-2'
    when 'bronze 3'
      'dance-level-bronze-3'
    when 'bronze 4'
      'dance-level-bronze-4'
    when 'silver 1'
      'dance-level-silver-1'
    when 'silver 2'
      'dance-level-silver-2'
    when 'silver 3'
      'dance-level-silver-3'
    when 'silver 4'
      'dance-level-silver-4'
    when 'gold 1'
      'dance-level-gold-1'
    when 'gold 2'
      'dance-level-gold-2'
    when 'gold 3'
      'dance-level-gold-3'
    when 'gold 4'
      'dance-level-gold-4'
    else
      'bg-secondary'
    end
  end
end
