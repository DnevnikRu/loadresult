# Load Result

#### Инструмент для генерации отчетов о нагрузочном тестировании

1. [Основные фунции](#user-content-functions)
* [Загрузка результатов](#user-content-upload_results)
* [Отчет по одному результату](#user-content-result_report)
* [Сравнение двух результатов](#user-content-compare_report)
* [Тренды](#user-content-trends)

2. [API](#user-content-api)
3. [Установка](#user-content-install)

<a name="functions"/>

## Основные функции

1. Загрузка и хранение результатов нагрузочных тестов
2. Генерация отчета о нагрузочном тесте
3. Генерация сравнительного отчета двуз нагрузочных тестов
4. Генерация отчета по нескольким нарузочных тестов (тренды)

<a name="upload_results"/>

### Загрузка результатов

При загрузке результатов на входе ожидаются файлы в формате csv. К формату файлов предъявляются строгие требования, описанные ниже.

Всего для одного результата можно загрузить 2 файла: 1
1. summary.csv - файл с данным о выполнявщихся запросов. Первая строка в файле - название столбцов. В файле должны присутствовать
следующие столбцы: 
* timeStamp
* label 
* responseCode
* bytes 
* grpThreads 
* allThreads
* URL
* Latency

2. perfmon.csv - файл с данными об утилизации ресурсов на серверах тестируемой системы. Первая строка в файле - название столбцов. В файле должны присутствовать
следующие столбцы:
* timeStamp
* elapsed
* label 
* grpThreads
* allThreads

Файлы такого формата, например, можно получить, если для нагрузочного тестирования вы используете[Jmeter](http://jmeter.apache.org/)
Файл с данными о запросах (summary.csv) формируется элементом [Summary Report](http://jmeter.apache.org/usermanual/component_reference.html#Summary_Report).
Чтобы получить нужный файл, необходимо настроить элемент как показано на рисунке:

![Configure summary](/screenshots/configure_summary.png?raw=true "Summary report")

Файл с данными о производительности серверов (perfmon.csv) можно получить, использовав плагин для Jmeter [PerfMon](https://jmeter-plugins.org/wiki/PerfMon/). 
Чтобы получить нужный файл, необходимо настроить элемент как показано на рисунке:

![Configure perfmon](/screenshots/configure_summary.png?raw=true "PerfMon")



##### Страница загрузки результатов

<a name="result_report"/>

### Отчет по одному результату

<a name="compare_report"/>

### Сравнение двух результатов

<a name="trends"/>

### Тренды

<a name="api"/>
 
## API


<a name="install"/>

## Установка 

### Локальная

1. Clone the repo https://github.com/DnevnikRu/loadresult.git
2. `bundle install` to install all necessary dependencies
3. `bundle exec rake db:setup` to create the database, load the schema and initialize it with the seed data
5. `rails server` to run the application
6. Go to `http://localhost:3000` in a browser

#### Install a database

##### OS X

1. `brew install postgres`
2. `pg_ctl -D /usr/local/var/postgres start`
3. `psql`
4. `CREATE USER postgres SUPERUSER;`
