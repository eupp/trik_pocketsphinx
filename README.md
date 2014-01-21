trik_pocketsphinx
================================

Скрипт для адаптирования голосовой модели pocketsphinx

Требования
-------------------------
Необходимо установить:

* [sphinxtrain] [1]
* [ru4sphinx] [2]  - утилиты для создания русского словаря
* [русская языковая модель] [3] 

Адаптирование языковой модели
-------------------------

Записываем команды, которые хотим распознавать, в .wav (для каждой команды свой файл) с частотой дискретизации 16000. 
Создаём два текстовых файла - commands.fileids и commands.transcription.
В файле .fileids перечисляем все .wav файлы (каждый с новой строки). 
В файле .transcription пишем текст, который записан в .wav файле в формате : \<s\> текст \</s\> (имя\_звукового\_файла).
Например, мы хотим адаптировать следующие команды: "вперёд", "назад", "стоп". Записываем .wav : back.wav, forward.wav, stop.wav .
Тогда .fileids будет выглядеть так:

	stop
	back
	forward

.transcription

	<s> стоп </s> (stop)
	<s> назад </s> (back)
	<s> вперёд </s> (forward)

Кроме того, нужно создать файл-словарь, содержащий все слова, которые pocketsphinx должен будет распознавать:

my_dictionary

	стоп
	вперёд
	назад

Также нужно определить грамматику языка. Используем [JSGF] [4] формат. Затем конвертируем грамматику в формат pocketsphinx: 

	sphinx_jsgf2fsg -jsgf grammar.jsgf -fsg grammar.fsg

Запускаем скрипт train.sh. Ему требуется 7 параметров (порядок важен):
1. Путь к акустической модели (папка zero_ru.cd_cont_4000 из скачанной русской модели)
2. Папка, куда будет сохранён результат работы (адаптированная модель и словарь)
3. Путь к ru4sphinx
4. Путь к словарю
5. Путь к файлу .fileids
6. Путь к файлу .transcription
7. Путь к sphinxtrain (по умолчанию /usr/local/libexec/sphinxtrain)

Результат работы скрипта папка acoustic с акустической моделью и файл словаря с расширением .dic .

Использование адаптированной модели
------------------------------------

	pocketsphinx_continuous -hmm acoustic/ -fsg grammar.fsg -dict dictionary.dic

Тестовая модель
----------------

В папке model находится тестовая модель с тремя командами: "вперёд", "назад", "стоп".


[1]: http://sourceforge.net/projects/cmusphinx/files/sphinxtrain/1.0.8/   "sphinxtrain"
[2]: https://github.com/zamiron/ru4sphinx "ru4sphinx"
[3]: http://sourceforge.net/projects/cmusphinx/files/Acoustic%20and%20Language%20Models/Russian%20Audiobook%20Morphology%20Zero/ "language model"
[4]: http://cmusphinx.sourceforge.net/sphinx4/javadoc/edu/cmu/sphinx/jsgf/JSGFGrammar.html "JSFG"
