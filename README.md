# terraform-spotlight
Déploiement via terraform d'une application web utilisant DynamoDB, API Gateway, S3, Lambda

Prérequis:
-	Configuration d'AWS & Terraform
-	Les autorisations nécessaires : DynamoDB, IAM, APIGateway, Lambda, S3
-	Modifier les deux variables dans "variables.tf"

Étape 1 – Déploiement de l'infrastructure :
Le fichier main.tf principal permet de créer DynamoDB, IAM, APIGateway et Lambda. Vous devez modifier deux variables dans "variables.tf" : la région (facultative) et votre identifiant AWS. Ensuite, exécutez la commande Terraform : "terraform init", puis"terraform apply".

Étape 2 – Récupération de l'URL de l'endpoint de l'API Gateway pour l'ajouter au fichier HTML :
Une fois l'infrastructure déployée, double-cliquez sur le script "replace_url.py" et sélectionnez "Créer un nouveau fichier HTML". Le script récupère automatiquement l'URL de l'endpoint de l'API Gateway déployée via Terraform et l'ajoute directement au fichier "html/speedlightterra.html". 

Cela permet à la commande "fetch" de récupérer les réponses de notre fonction Lambda. 
Si le script Python "replace_url.py" ne fonctionne pas, vous pouvez également modifier directement le fichier "html/speedlightterra.html" en remplaçant la valeur "REPLACE_WITH_API_GATEWAY_URL" à la ligne 53 par l'URL de l'endpoint de l'API, en plaçant cette URL entre guillemets, par exemple :

Avant modification :
-	fetch("https://8v424hhf2.execute-api.us-east-1.amazonaws.com/prod/resource", requestOptions)
Après modification :
-	fetch(REPLACE_WITH_API_GATEWAY_URL, requestOptions)

Pour obtenir l'URL de l'endpoint de l'API Gateway, exécutez la commande Terraform : 
-	"terraform output api_gateway_url".

Étape 3 – Test de fonctionnement :
Double-cliquez sur la page HTML "html/speedlightterra.html", entrez un nombre, puis cliquez sur "CALCULATE". Cela permettra de calculer le nombre entré grâce à la fonction Lambda, puis de renvoyer les résultats à l'utilisateur. Chaque entrée est enregistrée dans la base de données DynamoDB.

Étape 4 – Destruction de l'infrastructure :
Pour détruire l'infrastructure, exécutez la commande Terraform : 
-	"terraform destroy"

Étape 5 – Déploiement sur le stockage S3 (Optionnel) :
Si vous souhaitez héberger votre application web Speedlight sur un compartiment S3, exécutez la commande Terraform : "terraform apply" dans le dossier "/Upload S3 html speedlight/".
Cette étape n'est pas obligatoire, elle crée simplement un compartiment S3 web statique public. Vous pourrez ensuite y ajouter manuellement le contenu du dossier "html", ce qui permettra d'héberger l'application web Speedlight. 
La page "speedlightterra.html" deviendra la page d'accueil du site par défaut.

Note : 
À l'origine, cette partie devait être entièrement automatisée, avec la génération d'un nom unique pour la création du compartiment S3. 
Cependant, j'ai rencontré différents problèmes, et vous pouvez trouver plus de détails à ce sujet sur https://alexisguyot.click/. 
La partie d'upload automatique est en commentaire dans le fichier main.tf du dossier "terraform speedlight S3 upload". Il peut y avoir une erreur si un compartiment avec le même nom existe déjà sur AWS.

