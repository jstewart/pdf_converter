module Jms
  module PdfConverter
    @@ppmroot       = File.join(RAILS_ROOT, 'tmp', 'pdf_converter')
    mattr_accessor  :ppmroot
    
    class PDFError < StandardError;  end
    class ConversionError < StandardError;  end
    
    module ActMethods
      # Options:
      # *  <tt>:processor</tt> - Processor that converts PDF to image. image_magick or netpbm. image_magick is default.
      # *  <tt>:filname method</tt> - Instance method that returns the full path to the PDF file. :full_filename by default.
      # *  <tt>:processor_options</tt> - A string (for image_magick) or an array (for netpbm) of optional command line arguments to pass into the image processors.
      #
      # Examples:
      #   converts_pdf
      #   converts_pdf :processor => 'netpbm'
      #   converts_pdf :filename_method => :my_really_cool_method_that_returns_the_full_path
      #   converts_pdf :processor => 'netpbm', :processor_options => ['-q', '-v']
      #   converts_pdf :processor_options => '-density 150'
      def converts_pdf(options = {})
        options[:filename_method]     ||= :full_filename
        options[:processor]           ||= 'image_magick'
        options[:processor_options]   ||= ''
        
        if options[:processor_options].is_a?(String)
          options[:processor_options] = [options[:processor_options]]
        end
        
        extend ClassMethods unless (class << self; included_modules; end).include?(ClassMethods)
        include InstanceMethods unless included_modules.include?(InstanceMethods)
        
        self.pdf_options = options
        
        begin
          processor = Jms::PdfConverter::Processors.const_get("#{options[:processor].to_s.classify}Processor")
          include processor unless included_modules.include?(processor)
        rescue
          puts "Couldn't load #{processor.to_s} #{$!}"
          raise
        end
      end
      
      module ClassMethods
        def self.extended(base)
          base.class_inheritable_accessor :pdf_options
        end
        def filename_method
          pdf_options[:filename_method]
        end
      end
      
      module InstanceMethods
        def method_missing(method, *args)
          if format = method.to_s.match(/^convert_to_(\w+)$/)
            fmt     = format[1]
            process_pdf(fmt)
          else
            super
          end
        end
        
        protected
        
        def filename_for_pdf
          self.send(self.class.filename_method)
        end
        
        def is_pdf?
          self.filename_for_pdf =~ /\.pdf$/
        end
        
      end
      
    end  
  end
end