module Jms
  module PdfConverter
    module Processors
      module ImageMagickProcessor
      
        protected
        
        def process_pdf(format)
          path      = filename_for_pdf
          pdf_path  = path.sub(/pdf$/, format)
          
          if !self.is_pdf?
            raise Jms::PdfConverter::PDFError, "File is not a pdf" 
          end
          
          cmd = "convert #{pdf_options[:processor_options].shift.to_s} #{path} #{pdf_path}"
          `#{cmd}`
          if $? != 0
            raise Jms::PdfConverter::ConversionError, "#{cmd} falied" 
          end
        end
        
      end
    end
  end
end