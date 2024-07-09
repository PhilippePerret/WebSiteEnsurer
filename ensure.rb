#!/usr/bin/env ruby -U
# 

require 'clir'

module WebSiteEnsurer
class Site

  attr_reader :url
  attr_reader :term_searched

  def initialize(url, term_searched = nil)
    @url            = url
    @term_searched  = term_searched
  end

  def check
    res = %x(#{check_command})
    if res.split(' ')[-1] == "200"
      # <= OK
      if not(term_searched) || term_found?
        success
      end
    else
      # <= NOT OK (erreur HTTP)
      # => Double vérification
      
      if term_searched && term_found?
        # <= Finally OK
        success
      else
        # <= Vraiment NOT OK
        # puts "#{url} NOT OK".rouge
        # puts "HEADER:\n#{get_header}".rouge
        # puts "PAGE:\n#{get_page}".bleu
        failure
      end
    end
  end

  def success
    # puts "#{url} OK".vert
  end

  def failure
    notify_error
  end


  def notify_error(msg)
    `terminal-notifier -sound default -title "PROBLÈME DE SITE" -message "Le site #{url} ne répond plus…"`
  end

  def term_found?
    get_page.downcase.match?(term_searched.downcase)
  end

  def check_command
    @check_command ||= 'curl -s -I -X POST %s | head -n 1'.freeze % url
  end

  # En cas d’erreur, on récupère tout l’entête
  def get_header
    cmd = 'curl -s -I -X POST %s'.freeze % url
    `#{cmd}`
  end

  # En cas d’erreur, pour être sûr, on essaie de relever le 
  # contenu
  def get_page
    cmd = 'cUrl -s %s' % url
    res = `#{cmd}`
  end

  class << self
    def log(resultat)
      File.open(log_path,'a') do |f|
        f.write "Check du #{Time.now} : #{resultat}"
      end
    end
    def log_path
      @log_path ||= File.join(__dir__,'journal.log').freeze
    end
  end #/<< self

end #/class Site
end #/module WebSiteEnsurer

nombre_succes = 0
nombre_echecs = 0

sites_file = File.join(__dir__,'SITES.TXT')
IO.read(sites_file).strip.split("\n").each do |url|
  if WebSiteEnsurer::Site.new(*(url.split(';'))).check
    nombre_succes += 1
  else
    nombre_echecs += 1
  end
end
WebSiteEnsurer::Site.log("Success: #{nombre_succes} Failures: #{nombre_echecs}")
