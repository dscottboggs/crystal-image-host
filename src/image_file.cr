module ImageHost
  class Image
    property filepath : String
    getter? mime_type : String
    getter filename : String
    def initialize
      @filepath = File.join IMAGE_DIR, generate_filename
    end
    def initialize(@filename)
      @filepath = File.join IMAGE_DIR, filename
    end

    def set_mime_type
      @mime_type = `file --brief --mime #{filepath}`
    end

    def serve(to)
      ctx = to
      if mime_type?.nil?
        logger.debug "file isn't done being uploaded yet"
        ctx.response.status_code = PROCESSING
        ctx.write "wait".to_slice
        return
      end
      ctx.response.content_type = mime_type?.not_nil!
      File.open filepath do |file|
        IO.copy file, ctx.response
      end
    end

    def self.from_context?(ctx)
      if (req_body = ctx.request.body_io?).nil?
        return nil
      end
      outval = new
      spawn do
        File.open outval.filepath, mode: "w" do |f|
          IO.copy req_body, f
        end
        outval.set_mime_type
      end
      outval
    end

    def self.from_context(ctx)
      self.from_context?(ctx) || raise ImageHost::EmptyBody.new ctx
    end

    def generate_filename # todo add host
      digest = Digest::MD5.digest(Time.now.epoch_f).to_slice
      hash_size = digest.size/2
      hash_value = Bytes.new(hash_size)
      hash_size.times do |i|
        hash_value[i] = digest[i] ^ digest[i + hash_size]
      end
      Base64.urlsafe_encode(hash_value)
    end
  end
end
