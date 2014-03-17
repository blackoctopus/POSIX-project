
[Source](http://reviews.cnet.com/8301-13727_7-57574142-263/list-an-os-x-folder-hierarchy-with-textwrangler/ "Permalink to List an OS X folder hierarchy with TextWrangler | MacFixIt")

# List an OS X folder hierarchy with TextWrangler | MacFixIt

![][1]

The OS X Finder is a great tool to use for organizing your documents and projects into folder hierarchies; however, it is a bit limited. If you would like to save this hierarchy as a list in a file then the Finder and OS X does not provide these options. While the Finder does support printing a folder's listings by dragging a folder to a print queue, this is about the limit of the options for listing folder items.

One alternative to this is to use screenshots; however, these are static images in which items cannot be selected and copied, or otherwise managed.

Another alternative is to try using Automator, AppleScript, or shell scripts (including [tools like "tree" to list hierarchies][2]) to construct a workflow for this purpose; however, this can sometimes take a bit of development and testing, and be a daunting task especially for those who are not familiar with scripting languages.

[ ![Folder lines in TextWrangler][3]][4]

The folder lines in TextWrangler all contain a colon symbol, which can be used to extract them to a new document.

(Credit: Screenshot by Topher Kessler/CNET)

Despite this, an easier option does exist with the free TextWrangler utility that is [available for OS X from BareBones Software][5]. One feature that TextWrangler supports is the ability to create a tab-indented hierarchical tree of a folder's contents and display it in a text document by simply dragging a folder to a document's window. However, this feature will include all files and folders in the hierarchy, which may sometimes not be wanted.

If you are only interested in showing the folders in a directory structure and no files, then you can still do this by taking advantage of how TextWrangler manages folder notation in its directory listing feature.

In OS X the folder separator symbol is a forward slash; however, this is a change from the classic [ Mac][6] OS in which the folder separator was a colon. Nevertheless, OS X still recognizes the colon as a reserved symbol and will not by default allow it to be used in file names. However, in its directory listing feature, TextWrangler will use a colon to separate folders.

Since you are guaranteed for the most part that folder paths in TextWrangler will have a colon and file listings under these will not, you can use this difference to extract lines from a folder listing to only get a listing of the directories in a tree, instead of all files. To do this, run the following steps:

[ ![TextWrangler folder list][7]][8]

When finished, TextWrangler's new document will have only the hierarchy of folders shown.

(Credit: Screenshot by Topher Kessler/CNET)

  1. Launch TextWrangler and drag a desired folder to the blank document window.
  2. Select "Process Lines Containing" from the Text menu.
  3. Enter a single colon symbol in the "Find Lines Containing" field, and check the option to copy to a new document.
  4. Click the Process button.

With these steps run, TextWrangler will create a new document containing only the folder hierarchy tree for your desired Finder folder.




* * *

_Questions? Comments? Have a fix? Post them below or !
Be sure to check us out on [Twitter][9] and the [CNET Mac forums][10]._

   [1]: http://asset3.cbsistatic.com/cnwk.1d/i/tim/2012/08/29/TextWrangler_90x90.png
   [2]: http://reviews.cnet.com/8301-13727_7-10402034-263.html
   [3]: http://asset3.cbsistatic.com/cnwk.1d/i/tim/2013/03/13/TextWranglerProcessFolderLines_270x239.png
   [4]: http://i.i.cbsi.com/cnwk.1d/i/tim/2013/03/13/TextWranglerProcessFolderLines.png
   [5]: http://download.cnet.com/TextWrangler/3000-2351_4-10220012.html
   [6]: http://www.cnet.com/apple-mac.html
   [7]: http://asset0.cbsistatic.com/cnwk.1d/i/tim/2013/03/13/TextWranglerFolderExtraction_270x189.png
   [8]: http://i.i.cbsi.com/cnwk.1d/i/tim/2013/03/13/TextWranglerFolderExtraction.png
   [9]: http://twitter.com/mac_fix_it
   [10]: http://forums.cnet.com/mac-forums/
  