module UtilitySetup   
  
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}_#{base.name.underscore}.log")
  end
  
  module ClassMethods
    
    attr_accessor :start_time, :end_time, :logger
        
    def run
      process_thread = Thread.new { sleep(1); process }
      logger_filepath = 
        File.expand_path(logger.instance_variable_get(:@logdev).filename)
      File.open(logger_filepath, 'w') { |f| f.truncate(0) }
      File.open(logger_filepath) do |io|
        done = false
        until (done) do
          done = process_thread.join(1)
          while ( line = io.gets )  
            puts line
          end
        end
      end
    end
      
    private
    
      def process
        start
        work
        finish
      end
    
      def start
        self.start_time = Time.now
        logger.info "--- BEGIN: #{self.name} ---"
        logger.info "Starting: #{start_time}"
      end

      def finish
        self.end_time = Time.now
        logger.info "Finished at: #{end_time}"
        logger.info "Started at:  #{start_time}"
        logger.info "Elapsed:     #{end_time.to_f - start_time.to_f}"
        logger.info "--- END: #{self.name} ---"
      end
  
  end
  
end