trik_pocketsphinx
================================

Скрипт для адаптирования голосовой модели pocketsphinx

Требования
-------------------------
Необходимо установить:

* [sphinxtrain] [1]
* [ru4sphinx] [2]  - утилиты для создания русского словаря

Создание словаря
-------------------------

Создаём файл, содержащий все слова, которые pocketsphinx должен будет распознавать:

my_dictionary

	стоп
	вперёд
	назад

Запускаем скрипт dict.sh.
Параметры: <br />
1. Путь к ru4sphinx <br />
2. Путь к файлу со словами <br />
3. Имя выходного файла <br />

На выходе получаем файл-словарь, готовый для использования в pocketsphinx

Создание грамматики
-------------------------

Также нужно определить грамматику языка. Используем [JSGF] [3] формат. Пример:

```
#JSGF V1.0;

grammar example;

public <word> = <cmd>;

<cmd> =   вперёд
        | стоп
        | назад
        ;
```

Затем конвертируем грамматику в формат pocketsphinx: 

	sphinx_jsgf2fsg -jsgf grammar.jsgf -fsg grammar.fsg

Адаптирование языковой модели
-------------------------

Записываем команды, которые хотим распознавать, в .wav (для каждой команды свой файл) с частотой дискретизации 16000. 
Создаём два текстовых файла - commands.fileids и commands.transcription.
В файле .fileids перечисляем все .wav файлы (каждый с новой строки). 
В файле .transcription пишем текст, который записан в .wav файле в формате : 

	<s> текст </s> (имя_звукового_файла)

Например, мы хотим адаптировать следующие команды: "вперёд", "назад", "стоп". Записываем .wav : back.wav, forward.wav, stop.wav .
Тогда .fileids будет выглядеть так:

	stop
	back
	forward

.transcription

	<s> стоп </s> (stop)
	<s> назад </s> (back)
	<s> вперёд </s> (forward)

Запускаем скрипт *train.sh*. Ему требуется 7 параметров (порядок важен): <br />
1. Путь к акустической модели (папка zero\_ru.cd\_cont\_4000 из скачанной русской модели) <br />
2. Папка, куда будет сохранён результат работы (адаптированная модель и словарь) <br />
3. Путь к файлу .fileids <br />
4. Путь к файлу .transcription <br />
5. Путь к sphinxtrain (по умолчанию /usr/local/libexec/sphinxtrain) <br />

Результат работы скрипта папка acoustic с акустической моделью.

Использование адаптированной модели
------------------------------------

	pocketsphinx_continuous -hmm acoustic/ -fsg grammar.fsg -dict dictionary.dic

Русская модель
----------------

В папке model находится русская языковая модель zero_ru.cd_ptm_4000 [4]


[1]: http://sourceforge.net/projects/cmusphinx/files/sphinxtrain/1.0.8/   "sphinxtrain"
[2]: https://github.com/zamiron/ru4sphinx "ru4sphinx"
[3]: http://www.w3.org/TR/jsgf/ "JSFG"
[4]: http://sourceforge.net/projects/cmusphinx/files/Acoustic%20and%20Language%20Models/Russian/
