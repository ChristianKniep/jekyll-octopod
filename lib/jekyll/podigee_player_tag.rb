module Jekyll
  class PodigeePlayerTag < Liquid::Tag
    def playerconfig(context)
      config = context.registers[:site].config
      page = context.registers[:page]

      audio = {}
      download_url = config["download_url"] || config["url"] + "/episodes"
      page["audio"].each { |key, value| audio[key] = download_url + "/" + value}

      config = { options: { theme: "default",
                   startPanel: "ChapterMarks" },
        extensions: { ChapterMarks: {},
                      EpisodeInfo:  {},
                      Playlist:     {} },
        title: options['title'],
        episode: { media: audio,
                   coverUrl: config['url'] + (page["episode_cover"] || '/img/logo-360x360.png'),
                   title: page["title"],
                   subtitle: page["subtitle"],
                   url: config['url'] + page["url"],
                   description: page["description"],
                 }
      }
      if page.key?("chapters".to_sym)
        config["episode"]["chaptermarks"] = page["chapters"].map {|chapter| { start: chapter[0..12], title: chapter[13..255] }}
      end

      config.to_json
    end

    def render(context)
      config = context.registers[:site].config
      page = context.registers[:page]
      return unless page["audio"]
      return <<~HTML
        <script>
          window.playerConfiguration = #{playerconfig(context)}
        </script>
        <script class="podigee-podcast-player" data-configuration="playerConfiguration"
                src="#{config["url"].split(":").first}://cdn.podigee.com/podcast-player/javascripts/podigee-podcast-player.js">
        </script>
HTML
    end
  end
end

Liquid::Template.register_tag('podigee_player', Jekyll::PodigeePlayerTag)
