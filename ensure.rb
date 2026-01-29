#!/usr/bin/env ruby

require 'date'

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
      # <= OK l'url existe
      if term_searched && !term_found?
        failure("l'URL #{url} répond mais le terme « #{term_searched} » est introuvable.")
      else
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
        failure("L'URL est #{url} est inatteignable.")
      end
    end
  end

  def success
    # puts "#{url} OK".vert
    return true
  end

  def failure(errMsg)
    notify_error(errMsg)
    return false
  end

  # Notification d’une erreur
  def notify_error(errMsg)
    `terminal-notifier -sound default -title "PROBLÈME DE SITE" -message "#{errMsg}…"`
  end

  def term_found?
    get_page.force_encoding('UTF-8').downcase.match?(term_searched.downcase)
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
        f.write "Check du #{Time.now} : #{resultat}\n"
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
bons = []
bads = []
checks = [] # le 1er de chaque mois

sites_file = File.join(__dir__,'SITES.TXT')
IO.read(sites_file, encoding: 'UTF-8').strip.split("\n").each do |url|
  url, term = url.split(';')
  phrase = "#{url} (avec #{term})"
  if WebSiteEnsurer::Site.new(url, term).check
    nombre_succes += 1
    checks << "👍 #{phrase}"
  else
    nombre_echecs += 1
    bads << phrase
    checks << "💣 #{phrase}"
  end
end
WebSiteEnsurer::Site.log("Success: #{nombre_succes} Failures: #{nombre_echecs}")
if nombre_echecs > 0
  WebSiteEnsurer::Site.log("\tFailures:\n\t#{bads.join("\n\t")}")
end
if Date.today.day == 1
  WebSiteEnsurer::Site.log("\tDetails:\n\t#{checks.join("\n\t")}")
end
