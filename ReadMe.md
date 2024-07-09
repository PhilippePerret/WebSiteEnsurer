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
