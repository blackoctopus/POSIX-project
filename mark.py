import Tkinter
import urllib2
import webbrowser

clipString = Tkinter.Tk()

marky = 'http://heckyesmarkdown.com/go/?u='
queryString = (marky + str(clipString))

reqMD = urllib2.Request(queryString)
openMD = urllib2.urlopen(reqMD)
content = (openMD.read().decode('utf-8'))
Tkinter.Tk(content)


printf(content)
