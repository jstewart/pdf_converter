ActiveRecord::Base.send(:extend, Jms::PdfConverter::ActMethods)
FileUtils.mkdir_p(Jms::PdfConverter.ppmroot)