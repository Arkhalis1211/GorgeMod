/*
	Export intermediate data from AnimationCC to Don't Starve moodtools, for compile build data format.
	author: Surg
*/

function MathRound(val, increment) {
    increment = !increment || increment <= 0 ? 1 : increment;

    return Math.floor((val + increment / 2) / increment) / (1 / increment);
}

function DSSymbol()
{
    this.name = "";
    this.libraryInstance = null;
    this.libraryName = "";
    this.frames = [];
}

DSSymbol.prototype.addFrame = function(num, duration)
{
    this.frames.push({num: num, duration: duration, w: 0, h: 0, x: 0, y: 0});
}

DSSymbol.prototype.toPNG = function(doc, library, folderRootSymbol)
{
    for (var i = 0; i < this.frames.length; i++)
    {
        library.selectItem(this.libraryName, true);
        doc.exitEditMode();
        doc.addNewScene("__DELETE_ME__");
        library.addItemToDocument({x:0, y:0}, this.libraryName);
        doc.clipCut();        
        doc.deleteScene();            
        var _doc = fl.createDocument();
        _doc.clipPaste();
        _doc.selectAll();
        var element = _doc.selection[0];

        // hack for give true size frame :)
        _doc.enterEditMode();

		var _timeline = _doc.getTimeline();
		for (var l = 0; l < _timeline.layers.length; l++)
        {
            var layer = _timeline.layers[l];
			if (i < layer.frameCount)
            {
                _timeline.setSelectedLayers(l);
                _timeline.copyFrames(this.frames[i].num);
                _timeline.removeFrames(0, layer.frameCount);
                _timeline.pasteFrames(0);
            }
        }
        _doc.exitEditMode();
        element.symbolType = "movie clip";

        var padding_size = 0;
        var padding_step = 0;
        var reg_x = parseFloat(MathRound(-element.x + element.left, .00001).toFixed(2));
        var reg_y = parseFloat(MathRound(-element.y + element.top, .00001).toFixed(2));
        var width = Math.ceil(element.width) + padding_size;
        var height = Math.ceil(element.height) + padding_size;

        _doc.selectAll();
        _doc.width = width;
        _doc.height = height;

        element.x = Math.ceil((element.x - element.left) + padding_step);
        element.y = Math.ceil((element.y - element.top) + padding_step);

        var outFilePath = this.name + "-" + this.frames[i].num + ".png";

        this.frames[i].x = parseFloat((reg_x + ((element.width + padding_size) / 2)).toFixed(3));
        this.frames[i].y = parseFloat((reg_y + ((element.height + padding_size) / 2)).toFixed(3));
        this.frames[i].w = width;
        this.frames[i].h = height;

        _doc.exportPNG(folderRootSymbol + "/" + outFilePath, true, true);
        _doc.close(false);
    }
}

DSSymbol.prototype.toXML = function(index)
{
    var result = '\t<Symbol name="'+this.name+'">\r';

    for (var i = 0; i < this.frames.length; i++)
    {
        result += '\t\t<Frame framenum="'+this.frames[i].num+'" duration="'+this.frames[i].duration+'" image="'+this.name + "-" + this.frames[i].num+'" w="'+this.frames[i].w+'" h="'+this.frames[i].h+'" x="'+this.frames[i].x+'" y="'+this.frames[i].y+'"/>\r';
    }

    result += '\t</Symbol>\r';

    return result;
}

DSBuildXMLExporter = function()
{
    fl.outputPanel.clear();

    var scriptPath = fl.scriptURI;
    var scriptPathParts = scriptPath.split("/");
    var scriptName = scriptPathParts[scriptPathParts.length-1];
    var scriptDir = scriptPath.split(scriptName)[0];

    this.doc = fl.getDocumentDOM();
    this.library = this.doc.library;
    this.projectPath = this.doc.pathURI.replace(/[^.\/]+\.fla/, "");
    this.rootSymbolName = this.doc.getTimeline().name;
    this.symbols = [];

    var folderPath = this.projectPath + this.rootSymbolName;

    if (FLfile.exists(folderPath))
        FLfile.remove(folderPath);

    FLfile.createFolder(folderPath);
}

DSBuildXMLExporter.prototype.execute = function()
{
    for (var li = 0; li < this.library.items.length; li++)
    {
        var item = this.library.items[li];

        if (item.itemType == "graphic" && item.name.indexOf("FORCEEXPORT") != -1 && item.name.length > 11)
        {
            var symbolName = item.name.replace("FORCEEXPORT/", "");
            var symbol = new DSSymbol();

            symbol.name = symbolName;
            symbol.libraryInstance = item;
            symbol.libraryName = item.name;

            this.library.editItem(symbol.libraryName);
            var timeline = this.doc.getTimeline();
            var layer = null;
			var lastFrameNum = -1;

            for (var l = 0; l < timeline.layers.length; l++)
            {
                layer = timeline.layers[l];

                if (layer.visible)
                    break;        
            }

            for (var f = 0; f < layer.frameCount; f++)
            {
                var frame = layer.frames[f];

                if (frame.startFrame != lastFrameNum)
                {
                    lastFrameNum = frame.startFrame;

                    symbol.addFrame(lastFrameNum, frame.duration);
                }
            }

            this.symbols.push(symbol);
        }
    }

    this.doc.exitEditMode();

    for (var i = 0; i < this.symbols.length; i++)
    {
        var folderRootSymbol = this.projectPath + this.rootSymbolName;
        this.symbols[i].toPNG(this.doc, this.library, folderRootSymbol);
    }

    this.doc.exitEditMode();

    var xml = '<Build name="'+this.rootSymbolName+'">\r';    

    for (var i = 0; i < this.symbols.length; i++)
    {
        xml += this.symbols[i].toXML(i);
    }

    xml += '</Build>\r';

    FLfile.write(this.projectPath + this.rootSymbolName + "/build.xml", xml);
}

var exporter = new DSBuildXMLExporter();
exporter.execute();
