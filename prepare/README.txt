Dear Bonnie,

OK, I have got around to describe my pre-processing procedure in some detail. You may want to start from here and let me know if you need more information. It's all on the dropbox in the folder AppMovTar01/Analysis/. With that file structure, you get from .edf files to what I name .rea files, which contain all the information about the trial design, the saccades and their parameters. Since we're not starting from edf files, some initial steps might be different. For now, I put an edf file in the folder that you can use to try out the code.

Below, I try to be as explicit about the processing as I could.

I. Transform edf to ascii
(1) Put all .edf files in the folder prepare/
(2) Open a terminal window, navigate to that folder.
(3) Run ./prepare.sh (type this and hit enter). That transforms all .edf files into .msg and .dat files, puts them in the ../raw/ folder and moves the .edf files to the ../edf/ folder. You can open prepare.sh in a text editor to understand what it does. It's a simple shell script.

Note: prepare.sh requires having the edf2asc file available in your prepare/ folder ... simply putting it there is one strategy that should work, establishing a link to some central location is the more convenient option as it makes it available for all future projects (but requires some unix knowledge).

II. Parse msg files, create tab files
(1) Add all subject codes that should be part of the data structure to subjects.tmp and subjects.all. The latter should contain all subject codes, tmp only those that were added last ... if you keep running subjects, then using .msg for preprocessing takes less time, as pre-processing only works on the new files then.
(2) Open xmsg2tab.m in Matlab and run it. This creates .tab files that can then be found in the ../tab/ folder. By default, xmsg2tab.m works on files that are listed in the subjects.tmp file. The .tab files contain all the trial information extracted from the msg-part of the .edf files.

III. Detect saccades, and put trial + saccade data in individual .rea files
(1) Open xanaEyeMovements.m in Matlab.
(2) Set the welche parameter such that you include either subject.tmp or subjects.all for the analysis. Also, set the ABSTAND, MO_WIDE, MO_PHYS and scrCent parameter such that everything is how it was in the experiment. Saccade detection parameters probably also need considerable changes if we're working with 60 Hz.
(3) Run the file to create individual .rea files in the ../rea/ folder. If the plotData variable was set to 1, then you will get a plot of the eye position in the array of target stimuli, to illustrate if on that trial the eye movement was correct. You can click on the graph and the next trial will pop up. If you hit a key on the keyboard, the program will stop plotting and run through for the rest of the trials and files.

IV. Combine all individual rea files into one big .rea table
(1) Open xcombineData.m and run it. This creates a AllSubjects_V5D8T2S1000.rea file in the rea folder.

V. Understanding the combined rea file
(1) Each line in the .rea file is a trial.
(2) Each column in the .rea file is one variable, for that trial. This is a list of the variables for the eye movement experiment I ran:

1	Subject
2	Session
3	Block
4	Trial
5	fixation position x
6	fixation position y
7	test position x
8	test position y
9	standard timing
10	test timing
11	standard tilt
12	standard contrast
13 	test tilt
14	test contrast
15	tedfFix time stamp in edf file
16	tedfSOn rel. to tedfFix
17	tedfSOf rel. to tedfFix
18	tedfGo rel. to tedfFix
19	tedfTOn rel. to tedfFix
20	tedfTOf rel. to tedfFix
21	tSac
22	tRes
23	tedfClr rel. to tedfFix
24	saccade RT (determined on-line, use saccade satency instead)
25	manual RT
26	response for screen side
27	response for contrast
28	response for tilt
29	saccade required
30	saccade latency (determined off-line, use this)
31	reaSacNumber
32	sacType 
33	saccade onset time
34	saccade offset time
35	saccade duration
36	saccade peak velocity
37	saccade distance (from start to end point)
38	saccade angle 1 (from start to end point)
39	saccade amplitude (maximum excursion)
40	saccade angle 2 (for maximum excursion)
41	saccade x at onset
42	saccade y at onset
43	saccade x at offset
44	saccade y at offset

Note: In xanaEyeMovements.m I also transformed all y coordinates such that positive values are above the fixation point and negative values below.

For our experiment this list will need to be updated and changes in the code need to be made in different places. I will do all that, once we know what trial data we will have and need.

Let me know if you need any help!
Martin

