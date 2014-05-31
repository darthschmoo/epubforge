# My thinking is that, once the direct-from-source files are generated, further file formats can
# be handled by "converters" that take generated file X and convert to output file Y.

EpubForge::Utils::Converter.new do
  label          :epub_to_mobi_kindlegen
  input_format   :epub
  output_format  :mobi
  executable     "kindlegen"
  command        "{{x}} {{src}} -o {{dst}}"
  help           "Kindlegen is a command-line tool by Amazon, which can be downloaded at http://www.amazon.com/gp/feature.html?docId=1000765211"
end