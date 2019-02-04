
# Desplegar Drupal Mediante Ansible

**+Enunciado De La Práctica ASO (Ansible)+**

**Crea un escenario de forma automática utilizando la herramienta que prefieras: Vagrant, Terraform, Heat, etc. Este escenario incluirá dos máquinas, que llamaremos nodo1 y nodo2.**

**Configura apropiadamente nodo1 y nodo2 con ansible para instalar la aplicación drupal que funcione bajo drupal.example.com**

* **nodo1: PostgreSQL y Bind9**
* **nodo2: Apache con mod-php**

**El cliente simplemente levantará el escenario y configurará como DNS primario el de nodo1, para acceder a un drupal totalmente configurado en drupal.example.com. IMPORTANTE: No se considerará terminada la tarea si lo que aparece es el sistema de configuración del sitio en drupal, el sitio web tiene que estar totalmente configurado y listo para usar.**

**El resultado se tiene que proporcionar como un repositorio en github**



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

Los playbooks definidos para el escenario a montar, son dos ficheros de configuración "yaml", que son los ficheros "nodo1-conf.yaml" y "nodo2-conf.yaml", donde la configuración de los dos ficheros mostrados, se definirán en el fichero principal de montaje del escenario, que es el fichero "drupal.yaml".

La configuración adaptada en cada uno de los ficheros descritos, se mostrarán a continuación:

* **NODO1-CONF.YAML**

<pre>
---
- hosts: nodo1
  become: yes
  name: Instalación y Configuración Bind9 y PostgreSQL
  tasks:
  - name: Actualizar lista de paquetes
    apt: update_cache=yes
  - name: Instalar servidor DNS Bind9
    apt: name=bind9 state=latest
  - name: Copiar fichero de configuración named.conf.local
    copy: >
      src=files/bind9/etc/bind/named.conf.local 
      dest=/etc/bind/named.conf.local
  - name: Copiar fichero de configuracion /etc/bind/zones.rfc1918
    copy: >
      src=files/bind9/etc/bind/zones.rfc1918
      dest=/etc/bind/zones.rfc1918
  - name: Copiar fichero de configuración /var/cache/bind/db.example.com
    copy: >
      src=files/bind9/var/cache/bind/db.example.com
      dest=/var/cache/bind/db.example.com
      owner=bind
      group=bind
      mode=644
  - name: Copiar fichero de configuración /var/cache/bind/db.10.0.100
    copy: >
      src=files/bind9/var/cache/bind/db.10.0.100
      dest=/var/cache/bind/db.10.0.100 
      owner=bind
      group=bind
      mode=644
    notify: Reiniciar servicio dns Bind9
  - name: Instalar Sistema Gestor de Bases de Datos PostgreSQL
    apt: name={{ item }} update_cache=true state=installed
    with_items:
     - postgresql
     - libpq-dev
     - python-psycopg2
     - postgresql-contrib
    tags: packages
  - name: Creación de base de datos en PostgreSQL
    become: yes
    become_user: postgres
    vars:
      ansible_ssh_pipelining: true
    postgresql_db:
      name: drupal
      encoding: UTF-8
  - name: Creación de usuario en la base de datos de PostgreSQL y dar privilegios al usuario creado
    become: yes
    become_user: postgres
    vars:
      ansible_ssh_pipelining: true
    postgresql_user:
      db: drupal
      name: drupal
      password: drupal
      priv: "ALL"
      expires: infinity
  - name: Copiar fichero de configuración /etc/postgresql/9.6/main/postgresql.conf
    copy: >
      src=files/postgresql/etc/postgresql/9.6/main/postgresql.conf
      dest=/etc/postgresql/9.6/main/postgresql.conf
      owner=postgres
      group=postgres
  - name: Copiar fichero de configuración /etc/postgresql/9.6/main/pg_hba.conf
    copy: >
      src=files/postgresql/etc/postgresql/9.6/main/pg_hba.conf
      dest=/etc/postgresql/9.6/main/pg_hba.conf
      owner=postgres
      group=postgres
    notify:
     - Reiniciar SGBD PostgreSQL
  handlers:
  - name: Reiniciar SGBD PostgreSQL
    service:
      name: postgresql
      state: restarted
  - name: Reiniciar servicio dns Bind9
    service:
      name: bind9
      state: restarted
</pre>

Primero, actualizará los repositorios de paquetes del equipo Servidor "nodo1", y una vez actualizado, procederá con la instalación del Servidor DNS "bind9" en dicho equipo. A continuación, copiará los ficheros de configuración del Servidor DNS, que se encuentran en el directorio "playbooks/files/bind9" del equipo anfitrión, hacia el equipo Servidor "nodo1".

Seguidamente, procederá con la instalación del Sistema Gestor de Bases de Datos "PostgreSQL" en el equipo Servidor "nodo1", donde una vez instalado, copiará los ficheros de configuración del Sistema Gestor de Bases de Datos, que se encuentran en el directorio "playbooks/files/postgresql" del equipo anfitrión, hacia el equipo Servidor "nodo1".

En el siguiente paso, creará una base de datos llamada "drupal", y una vez creada dicha base de datos, se creará un usuario con contraseña en la base de datos, donde dicho usuario es "drupal" con contraseña "drupal" y cuando el usuario esté creado en la base de datos, se va a otorgar privilegios al usuario creado en la base de datos, hacia la base de datos "drupal", que es el usuario "drupal".

Por último, se reiniciará los servicios de "bind9" y "postgresql", para poder aplicar los cambios efectuados en el equipo Servidor "nodo1".

* **NODO2-CONF.YAML**

<pre>
---
- hosts: nodo2
  become: yes
  name: Instalar y Configurar Apache2
  tasks:
  - name: Actualizar lista de paquetes
    apt: update_cache=yes
  - name: Instalar servidor Web Apache2
    apt: 
      name= "{{ item }}"
    with_items:
     - apache2
     - apache-utils
    tags: packages
  - name: Instalar módulo PHP7.0-FPM para servidor Web Apache2
    apt:
      name: "{{ item }}"
    with_items:
     - libapache2-mod-php7.0
     - php7.0
     - php7.0-fpm
     - php-pgsql
     - php7.0-dom
     - php7.0-gd
     - php7.0-xml
     - php7.0-mbstring
    tags: packages
  - name: Instalar cliente de PostgreSQL en el equipo Servidor
    apt: name=postgresql-client state=latest
  - name: Descargar drush en el equipo Servidor
    get_url:
      url: https://github.com/drush-ops/drush/releases/download/8.1.17/drush.phar
      dest: /home/vagrant/drush.phar
  - name: Renombrar fichero drush descargado previamente
    command: mv drush.phar drush
  - name: Mover fichero drush al directorio /usr/local/bin/
    command: mv drush /usr/local/bin/drush
  - name: Dar permiso de ejecución al fichero drush
    command: chmod +x /usr/local/bin/drush
  - name: Instalar unzip en el equipo Servidor
    apt: name=unzip state=latest
  - name: Descargar drupal en el equipo Servidor
    get_url:
      url: https://ftp.drupal.org/files/projects/drupal-8.6.7.zip
      dest: /home/vagrant/drupal-8.6.7.zip
  - name: Descomprimir CMS drupal
    unarchive:
      src: /home/vagrant/drupal-8.6.7.zip
      dest: /var/www/html
      remote_src: yes
      owner: www-data
      group: www-data
      mode : 0755
  - name: Configurar virtualhost del sitio web de drupal
    copy: >
      src=files/apache2/etc/apache2/sites-available/drupal.conf
      dest=/etc/apache2/sites-available/drupal.conf
  - name: Deshabilitar sitio web por defecto de Apache2
    command: a2dissite 000-default.conf
  - name: Habilitar sitio web de drupal
    command: a2ensite drupal.conf
  - name: Habilitar modulo fast_cgi
    command: a2enmod proxy_fcgi
  - name: Habilitar configuración de PHP7.0-FPM
    command: a2enconf php7.0-fpm
  - name: Instalar drupal con drush
    command: > 
      drush si standard -y
      --site-name="Drupal de Kevin Ariza"
      --account-name="drupal"
      --account-pass="drupal"
      --db-url=pgsql://drupal:drupal@10.0.100.2/drupal
      -r /var/www/html/drupal-8.6.7 -y
  - name: Deshabilitar agregación de CSS con drush
    command: drush config-set system.performance css.preprocess 0 -r /var/www/html/drupal-8.6.7 -y
  - name: Deshabilitar agregación de JS con drush
    command: drush config-set system.performance js.preprocess 0 -r /var/www/html/drupal-8.6.7 -y
    notify: 
     - Reiniciar servicio web Apache
  handlers:
  - name: Reiniciar servicio web Apache
    service: 
      name=apache2
      state=restarted
</pre>

Primero, actualizará los repositorios de paquetes del sistema operativo, donde una vez actualizado dicho repositorios de paquetes, se instalarán el Servidor Web "Apache2", el módulo web "PHP7.0-FPM", el cliente del Sistema Gestor de Bases de Datos "PostgreSQL" y la herramienta "Drush", que es la herramienta encargada para la instalación del sitio web de "Drupal".

Seguidos de los pasos anteriores, se descargará la última versión de "Drupal" (actualmente la versión drupal-8.6.7), y una vez descargado, descomprimirá el archivo descargado, hacia el directorio "/var/www/html". Descomprimido los ficheros del CMS "Drupal", se copiarán los ficheros de configuración del Servidor Web "Apache2", que se encuentran en el directorio "playbooks/files/apache2", hacia el equipo Servidor "nodo2".

Luego, desactivará el sitio web por defecto de "Apache" y una vez desactivado, se habilitará el sitio web de "Drupal", el módulo "proxy_fcgi" y la configuración de "php7.0-fpm", para el Servidor Web "Apache".

Por último, se realizará la instalación del sitio web "Drupal", con la herramienta previamente descargada, que es la herramienta "Drush", en el equipo Servidor "nodo2", y una vez instalado el sitio web de "Drupal", se reiniciará el servicio de "apache2", para poder aplicar los cambios efectuados en el equipo Servidor "nodo2".

* **DRUPAL.YAML**

<pre>
- include: playbooks/nodo1-conf.yaml
- include: playbooks/nodo2-conf.yaml
</pre>

El fichero principal de ejecución de montaje del escenario de "Ansible", es el fichero "drupal.yaml", donde se definirán solamente, los ficheros de configuración de cada nodo, para que se ejecute de forma ordenada, como se observa en el estracto del fichero anteriormente reflejado.

Explicado como el escenario está montado y como está distribuido los ficheros de configuración del escenario con "Ansible", se mostrará los pasos a seguir, para poner en funcionamiento el escenario con "Ansible".

1. Ejecutar "vagrant up", para poder iniciar los dos equipos o nodos.
2. Ejecutar "ansible-playbook drupal.yaml"

