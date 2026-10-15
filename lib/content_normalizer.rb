# Stored export JSON often has literal \n sequences; markdown expects real newlines.
module ContentNormalizer
  module_function

  def normalize(text)
    text.to_s
      .gsub('\\r\\n', "\n")
      .gsub('\\n', "\n")
      .gsub('\\r', "\n")
      .gsub("\r\n", "\n")
      .gsub("\r", "\n")
  end
end

if $PROGRAM_NAME == __FILE__
  sample = 'line one\\n\\n  line two'
  normalized = ContentNormalizer.normalize(sample)
  raise 'expected real newlines' unless normalized.include?("\n\n")
  raise 'expected no literal backslash-n' if normalized.include?('\\n')

  puts 'ContentNormalizer ok'
end
