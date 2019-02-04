
# Desplegar Drupal Mediante Ansible

**Enunciado De La Práctica ASO (Ansible)**

Crea un escenario de forma automática utilizando la herramienta que prefieras: Vagrant, Terraform, Heat, etc. Este escenario incluirá dos máquinas, que llamaremos nodo1 y nodo2.

Configura apropiadamente nodo1 y nodo2 con ansible para instalar la aplicación drupal que funcione bajo drupal.example.com

* nodo1: PostgreSQL y Bind9
* nodo2: Apache con mod-php

El cliente simplemente levantará el escenario y configurará como DNS primario el de nodo1, para acceder a un drupal totalmente configurado en drupal.example.com. IMPORTANTE: No se considerará terminada la tarea si lo que aparece es el sistema de configuración del sitio en drupal, el sitio web tiene que estar totalmente configurado y listo para usar.

El resultado se tiene que proporcionar como un repositorio en github

<--->

El escenario a crear, consiste en la instalación y configuración de un sitio web de CMS "Drupal", mediante dos equipos o nodos, donde en cada nodo, se va a instalar los siguientes servicios a reflejarse:

* **Nodo 1:** Servidor DNS y Servidor de Base de Datos PostgreSQL
* **Nodo 2:** Servidor Web Apache2 con módulo web PHP7.0-FPM

Como se puede observar, el sitio web "Drupal" y el Sistema Gestor de Bases de Datos se encuentran en diferentes nodos, por lo que en la instalación del sitio web "Drupal", se indicará que el servidor de bases de datos, se encuentra en el equipo "nodo1".

El escenario que he montado, lo he distribuido de la siguiente manera:

* ansible.cfg: Fichero de configuración de acceso a través de Servidor "SSH", hacia los equipos o nodos del escenario, para realizar todos los pasos configurados, en los ficheros de configuración de "playbooks".
* ansible-hosts: Definición de los equipos del escenario, indicando su clave "SSH" de acceso a dichos equipos o nodos.
* drupal.yaml: Fichero principal a ejecutar, para poder montar el escenario por completo.
* playbooks: Directorio donde se encuentra todos los ficheros de configuración del escenario descrito y a montar.
* files: Directorio donde contiene todos los ficheros de configuración necesarios, para los servicios instalados, en cada uno de los nodos para el escenario a montar.
* Vagrantfile: Fichero donde contiene la información de los equipos del escenario, para poder levantarlos previamente a la ejecución del escenario con "Ansible".

En el directorio "playbooks/files", he creado tres carpetas, que son los siguientes a mostrarse:

* apache2.
* bind9.
* postgresql.

En cada uno de los directorios, he creado una serie de ficheros de configuración, donde los parámetros de dichos ficheros, se copiarán a los correspondientes nodos, donde se encuentran cada uno de los servicios instalados.

La distribución de los ficheros en la carpeta "files", es la siguiente:

<pre>
playbooks/files/
├── apache2
│   ├── etc
│   │   └── apache2
│   │       └── sites-available
│   │           └── drupal.conf
│   └── var
│       └── www
│           └── html
│               └── drupal-8.6.7
│                   └── settings.php
├── bind9
│   ├── etc
│   │   └── bind
│   │       ├── named.conf.local
│   │       └── zones.rfc1918
│   └── var
│       └── cache
│           └── bind
│               ├── db.10.0.100
│               └── db.example.com
└── postgresql
    └── etc
        └── postgresql
            └── 9.6
                └── main
                    ├── pg_hba.conf
                    └── postgresql.conf
</pre>

