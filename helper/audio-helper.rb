module ViddlRb

  # This class is responsible for extracting audio from video files using ffmpeg.
  class AudioHelper

    def self.extract(file_path, save_dir)
      no_ext_filename = file_path.split('.')[0..-1][0]
      #capture stderr because ffmpeg expects an output param and will error out
      puts "Gathering information about the downloaded file."
      file_info = Open3.popen3("ffmpeg -i #{file_path}") {|stdin, stdout, stderr, wait_thr| stderr.read }
      puts "Done gathering information about the downloaded file."

      if !file_info.to_s.empty?
        audio_format_matches = file_info.match(/Audio: (\w*)/)
        if audio_format_matches
          audio_format = audio_format_matches[1]
          puts "detected audio format: #{audio_format}"
        else
          raise "ERROR: Couldn't find any audio:\n#{file_info.inspect}"
        end
        
        extension_mapper = {
        'aac' => 'm4a',
        'mp3' => 'mp3',
        'vorbis' => 'ogg'
        }

        if extension_mapper.key?(audio_format)
          output_extension = extension_mapper[audio_format]
        else
          #lame fallback
          puts "Unknown audio format: #{audio_format}, using name as extension: '.#{audio_format}'."
          output_extension = audio_format
        end
        output_filename = File.join(save_dir, "#{no_ext_filename}.#{output_extension}")
        if File.exist?(output_filename)
          puts "Audio file seems to exist already, removing it before extraction."
          File.delete(output_filename)
        end
        Open3.popen3("ffmpeg -i #{file_path} -vn -acodec copy #{output_filename}") { |stdin, stdout, stderr, wait_thr| stdout.read }
        puts "Done extracting audio to #{output_filename}"
      else
        raise "ERROR: Error while checking audio track of #{file_path}"
      end
    end
  end

end
