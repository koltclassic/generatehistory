 load '~/markovtext/keys.rb'

 require 'rubygems'
 require 'mini_magick'
 require 'twitter'

 class MarkovChain
      def initialize(text)
        @words = Hash.new
        wordlist = text.split
        wordlist.each_with_index do |word, index|
          add(word, wordlist[index + 1]) if index <= wordlist.size - 2
        end
      end

      def add(word, next_word)
        @words[word] = Hash.new(0) if !@words[word]
        @words[word][next_word] += 1
      end

      def get(word)
        return "" if !@words[word]
        followers = @words[word]
        sum = followers.inject(0) {|sum,kv| sum += kv[1]}
        random = rand(sum)+1
        partial_sum = 0
        next_word = followers.find do |word, count|
          partial_sum += count
          partial_sum >= random
        end.first
        next_word
      end
    end

 def image_merge
      background = MiniMagick::Image.open('white.jpg')
      background.combine_options do |c|
        c.font "/Users/KoltEwing/Library/Fonts/BebasNeue.otf"
        c.pointsize 14
        c.gravity "center"
        c.annotate '0,0', "#{@tester}"
      end
      
      background.write 'output.jpg'
  end

  def tweet
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = CONSUMER_KEY
      config.consumer_secret     = CONSUMER_SECRET 
      config.access_token        = ACCESS_TOKEN 
      config.access_token_secret = ACCESS_TOKEN_SECRET
    end
    client.update_with_media(@formattedname, File.new("./output.jpg"))
  end

  #exec( ' echo ls | while read x; do echo "`expr $RANDOM % 1000`:$x"; done      | sort -n| sed "s/[0-9]*://"" | head -1 ')
  files = Dir.entries("./quotes/")

  rng_files = files.sample

  mc = MarkovChain.new(
    File.read("./quotes/#{rng_files}")
  )

  @sentence = ""
  word = "I"
  until @sentence.count(".") == 3
    @sentence << word << " "
    word = mc.get(word)
  end
  @sentence << "\n\n"

  #Add newlines on nth whitespace for formatting
  @tester = @sentence.split.map.with_index { |substr, i| (i != 0 && i % (10-1) == 0 )? substr+"\n" : substr+" " }.flatten.join

  #Regex to change file name to something more readable
  @formattedname = rng_files.match(/^(\w+?)\./).to_s.gsub!(/[\.|\_]/, ' ')

  image_merge
  tweet
