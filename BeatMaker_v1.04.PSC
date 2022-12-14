## BeatMaker.psc 
## (C) Leonidas SILVA JR. (State University of Paraíba, Brazil)
## Script for resynthesis of sound and pitch. This program transforms speech audios into beat 
## and melodic objects for voice comparison purposes. 
## This script can be used for voice comparison in:
## Pronunciation teaching (native/foreign language; Speech therapy (regular/) 
## For the sake of a finer comparison between vices,
## WE STRONGLY RECOMMEND USING - AT MOST - TWO AUDIO FILES PER FOLDER
##
##------##------##------ HOW TO CITE THIS SCRIPT ------##------##------##
## SILVA JR., Leonidas. (2022) BeatMaker (version 1.03). Computer program for Praat.
## Available in: <https://github.com/leonidasjr/VowelCode>.
 
form Set the input parameters
	comment *Set intensity minimum value for AUDIO/TEXT alignment
	real Intensity_threshold_(dB) 50.0
	comment The text file must have the same name of the reference sound
	word Reference_sound L1_speech
	comment Which target language are your audios? 
	optionmenu Language 1
		option English (America)
		option English (Great Britain)
		option Portuguese (Brazil)
		option Portuguese (Portugal)
		option French (France)
		option Spanish (Spain)
		option Spanish (Latin America)
		option Japanese
		option Russian
		option Interlingua
	choice Speaker_ID 2
		button Female
		button Male
		button Customize
	comment For *Costumize* option, set minimum and maximum Pitch values in the F0 threshold boxes
	integer left_F0_threshold_(Hz) 0.0
	integer right_F0_threshold_(Hz) 0.0
	optionmenu Native_language_F0_color 3
		option Black
		option Blue
		option Red
		option Green
		option Magenta
		option Purple
	optionmenu Foreign_language_F0_color 2
		option Black
		option Blue
		option Red
		option Green
		option Magenta
		option Purple
endform

## cleaning up plot area
Erase all

## cleaning up Praat's objects window and appended information before workflow
numberOfSelectedObjects = numberOfSelected()
if numberOfSelectedObjects > 0
	select all
	Remove
endif

## Creating TextGrid for the utterance containing automatic segmentation of words
ref_sound$ = reference_sound$ + ".wav"
Read from file... 'ref_sound$'
sound_file$ = selected$("Sound")
text$ = sound_file$ + ".txt"
text$ = readFile$(text$)

select Sound 'sound_file$'
	Edit
	editor Sound 'sound_file$'
		Intensity settings... 40 100 "mean energy" yes
		Close
	endeditor
select Sound 'sound_file$'
	To TextGrid: "sentence", ""
select Sound 'sound_file$'
	To Intensity... 100 0 0 yes 
	nframes = Get number of frames
for k from 1 to nframes
	int = Get value in frame: k
	if int > 'intensity_threshold'
		time = Get time from frame: k
		select TextGrid 'sound_file$'
		Insert boundary: 1, time
	endif
		select Intensity 'sound_file$'
endfor

select TextGrid 'sound_file$'
	b = 3
	repeat
		intervals = Get number of intervals: 1
		Remove left boundary: 1, b
		intervals = Get number of intervals: 1
	until b = intervals
Set interval text: 1, 2, text$

if language == 1 or language == 2 or language == 3
... or language == 4 or language == 5 or language == 6
... or language == 7 or language == 8 or language == 9
... or language == 10
	select Sound 'sound_file$'
		plus TextGrid 'sound_file$'
	View & Edit
	editor TextGrid 'sound_file$'
		Alignment settings: language$, "yes", "no", "yes"
		Align interval
		Close
	endeditor
endif
select TextGrid 'sound_file$'
	Set tier name: 1, "Text"
	Set tier name: 2, "Words"
select all
	minus TextGrid 'sound_file$'
Remove

select TextGrid 'sound_file$'
	Duplicate tier: 2, 1, "Words"
	Remove tier: 3

## Creating rhythmic and pitch sound files
Create Strings as file list... audioDataList *.wav
numberOfFiles = Get number of strings

for y from 1 to numberOfFiles
    select Strings audioDataList
    filename$ = Get string... y
    Read from file... 'filename$'
	soundFile$ = selected$ ("Sound")
    language_chr$ = mid$(soundFile$, 1, 2)

	if speaker_ID == 1
    	select Sound 'soundFile$'
			To Pitch... 0.0 90 350
			To Sound (pulses)
			Rename... 'language_chr$'_pulses_temp
		select Pitch 'soundFile$'
			To Sound (sine): 44100, "at nearest zero crossings"
		Multiply: 4
		Rename... 'language_chr$'_sine_temp
	elsif speaker_ID == 2
		select Sound 'soundFile$'
			To Pitch... 0.0 75 200
			To Sound (pulses)
			Rename... 'language_chr$'_pulses_temp
		select Pitch 'soundFile$'
			To Sound (sine): 44100, "at nearest zero crossings"
		Multiply: 4
		Rename... 'language_chr$'_sine_temp
	elsif speaker_ID == 3
		select Sound 'soundFile$'
			To Pitch... 0.0 'left_F0_threshold' 'right_F0_threshold'
			To Sound (pulses)
			Rename... 'language_chr$'_pulses_temp
		select Pitch 'soundFile$'
			To Sound (sine): 44100, "at nearest zero crossings"
		Multiply: 4
		Rename... 'language_chr$'_sine_temp
	endif

	select Sound 'language_chr$'_sine_temp
		plus Sound 'language_chr$'_pulses_temp
	Combine to stereo
	Rename... 'language_chr$'_Beat
	Convert to mono
		plus Sound 'soundFile$'
	Combine to stereo
	Rename... 'language_chr$'_BeatVoice
	select Sound 'language_chr$'_sine_temp
		plus Sound 'language_chr$'_pulses_temp
	Remove
	select Pitch 'soundFile$'
	To Sound (hum)
	Rename... 'language_chr$'_Pitch

	## Plot procedures
	Font size: 14
	Times
	if language_chr$ == "L1" or language_chr$ == "NS" or language_chr$ == "CV" or language_chr$ == "V1" or language_chr$ == "SV"
		select Pitch 'soundFile$'
		Smooth: 2
		'native_language_F0_color$'
		Select outer viewport: 0, 10, 0, 4.5
		Draw inner box
		if speaker_ID == 1
			Draw: 0, 0, 90, 350, "no"
			Line width: 2
			Draw: 0, 0, 90, 350, "no"
		elsif speaker_ID == 2
			Draw: 0, 0, 75, 200, "no"
			Line width: 2
			Draw: 0, 0, 75, 200, "no"
		elsif speaker_ID == 3
			Draw: 0, 0, 'left_F0_threshold', 'right_F0_threshold', "no"
			Line width: 2
			Draw: 0, 0, 'left_F0_threshold', 'right_F0_threshold', "no"
		endif
		Line width: 1
		Marks left: 6, "yes", "yes", "yes"
		Marks bottom: 6, "yes", "yes", "yes"
		Text left: "yes", "Pitch (fundamental frquency in Hz)"
		Text bottom: "yes", "Time (duration in seconds)"
		select TextGrid 'soundFile$'
		Black
		Select outer viewport: 0, 10, 1.5, 4.5
		Draw: 0, 0, "yes", "yes", "no"

		Font size: 14
		Line width: 1
		Select outer viewport: 7.5, 10, 0, 1.77
		Draw inner box
		'native_language_F0_color$'
		Text special: 1, "left", 0, "half", "Helvetica", 15, "0", language_chr$

		select Pitch 'soundFile$'
		Remove
		select Pitch 'soundFile$'
			plus Sound 'language_chr$'_Beat_mono
		Remove
	
	elsif language_chr$ == "L2" or language_chr$ == "FS" or language_chr$ == "EV" or language_chr$ == "V2" or language_chr$ == "QV"
		'foreign_language_F0_color$'
		Text special: 1, "left", -1, "half", "Helvetica", 15, "0", language_chr$
		select Pitch 'soundFile$'
		Smooth: 2
		'foreign_language_F0_color$'
		Select outer viewport: 0, 10, 0, 4.5
		Draw inner box
		Line width: 2
		Line width: 1
		Select outer viewport: 0, 10, 0, 4.5
		Draw inner box
		if speaker_ID == 1
			Draw: 0, 0, 90, 350, "no"
			Line width: 2
			Draw: 0, 0, 90, 350, "no"
			Line width: 1
		elsif speaker_ID == 2
			Draw: 0, 0, 75, 200, "no"
			Line width: 2
			Draw: 0, 0, 75, 200, "no"
			Line width: 1
		elsif speaker_ID == 3
			Draw: 0, 0, 'left_F0_threshold', 'right_F0_threshold', "no"
			Line width: 2
			Draw: 0, 0, 'left_F0_threshold', 'right_F0_threshold', "no"
			Line width: 1
		endif
		
		select Pitch 'soundFile$'
		Remove
		select Pitch 'soundFile$'
			plus Sound 'language_chr$'_Beat_mono
		Remove
	else
		exitScript "WARNING! Your files must be tagged with at least the characters: 
		... L1 or NS or CV or V1 or SV (Reference audio and text files) 
		... and L2 or FS or EV or V2 or QV (Experimental audio file)"
		#writeInfoLine: " %% WARNING %%! ", "Your files must be tagged with at least"
		#	appendInfoLine: "the folowing characters:"
		#	appendInfoLine: ""
		#	appendInfoLine: "Reference audio and text files"
		#	appendInfoLine: "L1 or NS or CV or V1 or SV"
		#	appendInfoLine: ""
		#	appendInfoLine: "Experimental audio file"
		#	appendInfoLine: "L2 or FS or EV or V2 or QV"
		Remove
		select Pitch 'soundFile$'
			plus Sound 'language_chr$'_Beat_mono
		Remove
	endif
	select Strings audioDataList
endfor