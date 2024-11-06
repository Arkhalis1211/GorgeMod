/*
	Export intermediate data from AnimationCC to Don't Starve moodtools, for compile animation data format.
	author: Surg
*/

function CopyTimeline(srcTimeline, dstTimeline)
{
    if (srcTimeline.layers.length == 0) return false

    srcTimeline.copyLayers(0, srcTimeline.layers.length);
    dstTimeline.pasteLayers();

    return true
}

function DSElementFrame()
{
    this.name = "";
    this.foldername = "";
    this.frame = 0;
    this.m_a = 0;
    this.m_b = 0;
    this.m_c = 0;
    this.m_d = 0;
    this.m_tx = 0;
    this.m_ty = 0;
    this.z_order = 1;
}

DSElementFrame.prototype.toXML = function(z_index)
{
    return '\t\t\t<element name="'+this.name+'" layername="'+this.foldername+'" frame="'+this.frame+'" z_index="'+z_index+'" m_a="'+this.m_a+'" m_b="'+this.m_b+'" m_c="'+this.m_c+'" m_d="'+this.m_d+'" m_tx="'+this.m_tx+'" m_ty="'+this.m_ty+'"/>\r';
}

function DSAnimationFrame()
{
    this.x = 0;
    this.y = 0;
    this.w = 0;
    this.h = 0;
    this.elements = [];
}

DSAnimationFrame.prototype.addElement = function(name, foldername, frame, z_order, m_a, m_b, m_c, m_d, m_tx, m_ty)
{
    var element = new DSElementFrame();

    element.name = name;
    element.foldername = foldername;
    element.frame = frame;
    element.m_a = m_a;
    element.m_b = m_b;
    element.m_c = m_c;
    element.m_d = m_d;
    element.m_tx = m_tx;
    element.m_ty = m_ty;
    element.z_order = z_order;

    this.elements.push(element);
}

DSAnimationFrame.prototype.toXML = function()
{
    var result = '\t\t<frame w="'+this.w+'" h="'+this.h+'" x="'+this.x+'" y="'+this.y+'">\r';

    for (var i = 0; i < this.elements.length; i++)
    {
        result += this.elements[i].toXML(i);
    }

    result += '\t\t</frame>\r';

    return result;
}

function DSAnimation(rootSymbolName)
{
    this.name = "";
    this.rootSymbolName = rootSymbolName;
    this.framerate = 30;
    this.frames = [];
    this.firstFrameIndex = 0;
    this.lastFrameIndex = 0;
}
    
DSAnimation.prototype.addBlankFrame = function()
{
    var frame = new DSAnimationFrame();

    this.frames.push(frame);

    return this.frames[this.frames.length-1];
}

DSAnimation.prototype.toXML = function()
{
    var numframes = this.frames.length;
    var result = '\t<anim name="'+this.name+'" root="'+this.rootSymbolName+'" numframes="'+numframes+'" framerate="'+this.framerate+'">\r';

    for (var i = 0; i < this.frames.length; i++)
    {
        result += this.frames[i].toXML();
    }

    result += '\t</anim>\r';

    return result;
}

DSAnimationXMLExporter = function()
{
    fl.outputPanel.clear();

    var scriptPath = fl.scriptURI;
    var scriptPathParts = scriptPath.split("/");
    var scriptName = scriptPathParts[scriptPathParts.length-1];
    var scriptDir = scriptPath.split(scriptName)[0];

    this.mainDoc = fl.getDocumentDOM();
    this.projectPath = this.mainDoc.pathURI.replace(/[^.\/]+\.fla/, "");
    this.rootSymbolName = this.mainDoc.getTimeline().name;
    this.mainTimeline = this.mainDoc.getTimeline();
    this.framerate = this.mainDoc.frameRate;
    this.animations = [];

    var folderPath = this.projectPath + this.rootSymbolName;

    if (!FLfile.exists(folderPath))
        FLfile.createFolder(folderPath);

    this.doc = fl.createDocument();
    this.timeline = this.doc.getTimeline();
    this.library = this.doc.library;

	CopyTimeline(this.mainTimeline, this.timeline);

    this.timeline.deleteLayer(this.timeline.layers.length - 1);
}

DSAnimationXMLExporter.prototype.setAnimation = function (name, frameIndex)
{
    for (var i = 0; i < this.animations.length; i++)
    {
        if (this.animations[i].name == name)
        {
            this.animations[i].lastFrameIndex = frameIndex;

			return this.animations[i];
        }
    }

    var animation = new DSAnimation(this.rootSymbolName);

    animation.name = name;
    animation.framerate = this.framerate;
    animation.firstFrameIndex = frameIndex;
    animation.lastFrameIndex = frameIndex;

    this.animations.push(animation);

    return animation;
}

DSAnimationXMLExporter.prototype.getFrame = function(frameIndex)
{
    for (var a = 0; a < this.animations.length; a++)
    {
        if (frameIndex >= this.animations[a].firstFrameIndex  && frameIndex <= this.animations[a].lastFrameIndex)
        {
            var index = frameIndex - this.animations[a].firstFrameIndex;

            return this.animations[a].frames[index];
        }
    }

    return null;
}

DSAnimationXMLExporter.prototype.prepare = function()
{    
    if (this.timeline.layers.length == 0) return false;
     
    var maxLenAnim = 0;

    for (var l = 0; l < this.timeline.layers.length; l++)
    {
        var layer = this.timeline.layers[l];
        
        if (layer.layerType == "guide" && layer.name == "animations")
		{
            for (var f = 0; f < layer.frameCount; f++) {
                var frame = layer.frames[f];
                this.setAnimation(frame.name, f);
            }
        }

        if (layer.visible && layer.layerType == "normal") {
            if (layer.frameCount > maxLenAnim) {
                maxLenAnim = layer.frameCount - 1
            }

            this.timeline.setSelectedLayers(l);
            this.timeline.convertToKeyframes(1, layer.frameCount);
        }
    }

    if (this.animations.length == 0)
    {
        var animation = new DSAnimation(this.rootSymbolName);

        animation.id = this.animations.length;
        animation.name = "anim";
        animation.framerate = this.framerate;
        animation.firstFrameIndex = 0;
        animation.lastFrameIndex = maxLenAnim;

        this.animations.push(animation);
        fl.trace("Warning: Animations markers not found, create default: anim");
    }    

    for (var a = 0; a < this.animations.length; a++)
    {
        var count = (this.animations[a].lastFrameIndex - this.animations[a].firstFrameIndex) + 1;

        for (var i = 0; i < count; i++)
        {
            this.animations[a].addBlankFrame();
        }            
    }
    
    fl.getDocumentDOM().selectNone();

    return true;
}

DSAnimationXMLExporter.prototype.execute = function()
{
    if (this.prepare())
	{
        for (var l = 0; l < this.timeline.layers.length; l++)
		{
            var layer = this.timeline.layers[l];

            if (layer.visible && layer.layerType == "normal")
			{
                for (var f = 0; f < layer.frameCount; f++)
				{
                    var frame = layer.frames[f];
                    var animFrame = this.getFrame(f);

                    if (animFrame != null && frame.elements.length == 1)
					{
                        var element = frame.elements[0];
                        var m_a = element.matrix.a;
                        var m_b = element.matrix.b;
                        var m_c = element.matrix.c;
                        var m_d = element.matrix.d;
                        var m_tx = element.matrix.tx;
                        var m_ty = element.matrix.ty;
                        
                        var lib_name = element.libraryItem.name;
                        var lib_name_bi = element.libraryItem.name.lastIndexOf("/");
                        if (lib_name_bi != -1)
                            lib_name = lib_name.substr(lib_name_bi + 1);

                        element.selected = true;
                        animFrame.addElement(lib_name, layer.name, element.firstFrame, l, m_a, m_b, m_c, m_d, m_tx, m_ty);                        
                    }

                    if (frame.elements.length > 1)
                        fl.trace("Warning: [layer " + layer.name + ", frame "+ (f + 1) +"] have more 1 elements, this is unacceptable.");
                }
            }
        }

        for (var f = 0; f < this.timeline.frameCount; f++)
		{
            var animFrame = this.getFrame(f);

            if (animFrame != null)
			{
                this.timeline.currentFrame = f;
                var rect = this.doc.getSelectionRect();
                var w = parseFloat((-rect.left + rect.right).toFixed(2));
                var h = parseFloat((-rect.top + rect.bottom).toFixed(2));
                var dx = parseFloat((rect.left + (w / 2)).toFixed(2));
                var dy = parseFloat((rect.top + (h / 2)).toFixed(2));

                animFrame.x = dx;
                animFrame.y = dy;
                animFrame.w = w;
                animFrame.h = h;
            }
        }

        var xml = '<Anims>\r';

        for (var i = 0; i < this.animations.length; i++)
        {
            xml += this.animations[i].toXML();
        }

        xml += '</Anims>\r';

        FLfile.write(this.projectPath + this.rootSymbolName + "/animation.xml", xml);
    }

    this.doc.selectNone();
    this.doc.close(false);
}

var exporter = new DSAnimationXMLExporter();
exporter.execute();
