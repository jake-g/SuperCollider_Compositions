/* DXARTS 461 Digital Sound Synthesis: Class 1 - Orientation & Environment */

/*
Introductions

Joseph Anderson: http://www.dxarts.washington.edu/people/49-Joseph-Anderson
                 http://joseph-anderson.org
                 http://www.ambisonictoolkit.net

Hector Bravo Benard: http://www.dxarts.washington.edu/people/41-Hector-Bravo-Benard
                     http://www.hbbenard.com/HectorBravoBenard/About.html

*/

/*

• Class list (sort out any registration problems) / attendance

• Brief intro about class
	-Who we are
	-What this class is:
          weekly topics
          assignments (inc reading)
          midterm / final
	-What this class is not
	-5 credits = lots of work
	-Grades: attendance+readings+listenings+assigments+midterm+final

• Review the Catalyst page (https://canvas.uw.edu/courses/880932)

• Logistics
    -Software: SuperCollider, download from (install on Thursday):

	http://supercollider.sourceforge.net/downloads/

    -Book: Charles Dodge and Thomas Jerse, "Computer Music, Synthesis Composition, and Performance" (you can get it at the U. Bookstore)

    -Mailing list: TBA

	-Labs

	-Codes and Keys

• Events (required!)
	-Melia Watras, viola, Monday Jan 13, 7:30pm Meany Hall.

• Introductions by students

• Visit of lab (lab policy)

*/





/*
Acknowledgements

Much of the material we will be using for this course is adapted from teaching material developed by my colleagues Josh Parmenter, Stelios Manousakis, and Juan Pampin at DXARTS, University of Washington, USA.

Josh Parmenter:		http://www.dxarts.washington.edu/people/30-Josh-Parmenter
Stelios Manousakis:	http://www.dxarts.washington.edu/people/8-Stelios-Manousakis
Juan Pampin:		http://www.dxarts.washington.edu/people/13-Juan-Pampin
*/


/*
Resources, VLE

Canvas:		https://canvas.uw.edu/courses/880932


***** I HIGHLY suggest you purchase a USB memory stick to save class work on, and that you back up the files on that memory stick regularly. While class notes are very small (4k usually) soundfiles can be quite large. I suggest at least an 8GB thumb drive. ******
*/


/*
Software

At this point you may have worked out that we'll be using SuperCollider in this course. SuperCollider (http://supercollider.sourceforge.net) is a modern, mature and powerful MUSIC V family object oriented computer music language. It is similar in functionality to the graphical patching systems Max/MSP and Pd, but because it it text based, SuperCollider has much more flexibility.

*/


/*
SuperCollider mailing list

Along with purchasing The SuperCollider Book (see above) you are strongly advised to sign up to the SuperCollider mailing list:

http://www.birmingham.ac.uk/facilities/BEAST/research/supercollider/mailinglist.aspx

Here you can view ongoing conversations about SuperCollider, view questions posted by other users, ask your own questions, get support from 'power users'
*/



/* DOWNLOADS */
/*
While SuperCollider will be installed in Raitt 129, I expect most class members will like to have the flexibility of working on a personal machine. Go ahead and install SC on your machine this week. (We'll look at installing extensions, Quarks and sc3-plugins in the lab on Thursday.)


For stable release downloads of the SuperCollider language and synthesis server, go to:

	http://supercollider.sourceforge.net/downloads/

This link will give you basic downloads and instructions. You will also want sc3-plugins and you will need to check out a version of the Quarks (much more on this later).


-----------
Quarks (http://quarks.sourceforge.net)

See Using Quarks in the SuperCollider help documents. Select [Using Quarks], then select 'SuperCollider Help' from the Help menu.

Follow the first method under 'Obtaining quarks' to install for your system.

Once you have checked out a version of Quarks, you will want to install the Ctk, Tendency, WarpExt and MathLib Quarks. I suggest using the Quarks.gui command to choose Quarks to install.

http://quarks.svn.sourceforge.net/viewvc/quarks/Ctk/
http://quarks.svn.sourceforge.net/viewvc/quarks/Tendency/
http://quarks.svn.sourceforge.net/viewvc/quarks/WarpExt/
http://quarks.svn.sourceforge.net/viewvc/quarks/MathLib/

*/


/*

Stelios Manousakis, University of Washington, 2011
Joseph Anderson, University of Kent, 2012
Joseph Anderson, University of Washington, 2013

*/