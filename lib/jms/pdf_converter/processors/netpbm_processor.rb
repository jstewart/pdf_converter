module Jms
  module PdfConverter
    module Processors
      module NetpbmProcessor
        
        FORMAT_MAP = {"jpg" => "jpeg"}
        
        protected
        
        def process_pdf(format)
          path        = filename_for_pdf
          ppm_path    = File.join(Jms::PdfConverter.ppmroot, self.id.to_s)
          real_format = Jms::PdfConverter::Processors::NetpbmProcessor::FORMAT_MAP.fetch(format, format)
          
          if !self.is_pdf?
            raise Jms::PdfConverter::PDFError, "File is not a pdf" 
          end
          
          FileUtils.mkdir_p(ppm_path)
          ppm_cmd = "pdftoppm #{pdf_options[:processor_options].shift.to_s} #{path} #{ppm_path}/"
          exec_with_error_checking(ppm_cmd)
          ppms = Dir.glob("#{ppm_path}/*.ppm")
          multiple_pages = ppms.length > 1
          
          ppms.each_with_index do |p, index| 
            outfile = output_filename(path, format, index, multiple_pages)
            
            pnmconvert = "pnmto#{real_format} #{pdf_options[:processor_options].shift.to_s} #{p} > #{outfile}"
            exec_with_error_checking(pnmconvert)
          end
          
          FileUtils.rm_rf(ppm_path)
        end
        
        private
        
        def exec_with_error_checking(cmd)
          `#{cmd}`
          if $? != 0
            raise Jms::PdfConverter::ConversionError, "#{cmd} falied" 
          end
        end
        
        def output_filename(path,format, index, multi=false)
          if multi
            format_str = path.sub(/\.pdf$/, "-%d." + format)
            sprintf(format_str, index)
          else
            path.sub(/pdf$/, format)
          end
        end
        
      end
    end
  end
end