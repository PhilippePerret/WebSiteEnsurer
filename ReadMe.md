# Web Site Ensurer

Programme pour un cron job s’assurant qu’un site fonctionne.

Les sites à vérifier doivent se trouver dans le fichier ./SITES.TXT, les uns au-dessous des autres. Par exemple :

~~~
https://www.atelier-icare.net
https://www.philippeperret.fr
https://www.icare-editions.fr
~~~

On peut augmenter la recherche d’erreur en ajoutant un texte à trouver dans la page, après l’url :

~~~
https://www.atelier-icare.net;atelier icare
https://www.philippeperret.fr;philippe perret
https://www.icare-editions.fr;icare éditions
~~~

> Noter que ce texte sert autant à valider la page en cas de succès qu’à la contrôler en cas d’échec. Car parfois, pour une raison que je ne comprends pas encore, une erreur 500 est produite alors que la page est correctement atteinte.

## Lancement du check par cronjob

Pour régler/lancer le cronjob, sur macOs, jouer :

~~~
crontab -e
~~~

… pour éditer le cron-job et mettre à l’intérieur :

~~~
30 * * * * ruby path/to/file.ensure.rb 2>&1
~~~

… pour checker les sites toutes les heures, à la demie.


## Problème de cron

Si une erreur se produit mais qu’aucun message d’erreur n’est retourné, on peut utiliser `launchd` pour remplacer le crontab, qui est plus verbeux.

Pour ce faire, créer un fichier `com.philou.cronjob.plist ` dans `~/Library/LaunchAgents` et y copier le code :

~~~
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.philou.cronjob</string>
    <key>ProgramArguments</key>
    <array>
      <string>/Users/philippeperret/.rbenv/shims/ruby</string>
      <string>/Users/philippeperret/Programmes/WebSiteEnsurer/ensure.rb</string>
    </array>
    <key>StartInterval</key>
    <integer>120</integer> <!-- Exécute toutes x secondes -->
    <key>StandardOutPath</key>
    <string>/Users/philippeperret/Programmes/WebSiteEnsurer/output.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/philippeperret/Programmes/WebSiteEnsurer/error.log</string>
  </dict>
</plist>
~~~

Lancer cette boucle avec :

~~~
launchctl load ~/Library/LaunchAgents/com.philou.cronjob.plist 
~~~

L’arrêter lorsque le problème est résolu avec :

~~~
launchctl unload ~/Library/LaunchAgents/com.philou.cronjob.plist 
~~~
