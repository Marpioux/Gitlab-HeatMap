Class {
	#name : 'Design',
	#superclass : 'Object',
	#instVars : [
		'sunBuilder'
	],
	#category : 'Gitlab-Sunburst-Explorer',
	#package : 'Gitlab-Sunburst-Explorer'
}

{ #category : 'as yet unclassified' }
Design >> DynamicSunburstFor: aTree withLeafs: aLeafName [
	| sb canvas newData color newAnimation first interpolate label interaction legend |
	canvas := RSCanvas new.

	color := NSScale category20c.
	newData := nil.
	newAnimation := [ :from :to |
		canvas newAnimation
			easing: RSEasingInterpolator bounceOut;
			from: from;
			to: to;
			duration: 50 milliSeconds;
			yourself ].

	interpolate := [ :oldShape :newShape :target |
		(oldShape notNil and: [newShape notNil]) ifTrue: [
			(newAnimation value: oldShape alphaAngle value: newShape alphaAngle) onStepDo: [ :t |
				target alphaAngle: t.
				canvas signalUpdate ].
			(newAnimation value: oldShape betaAngle value: newShape betaAngle) onStepDo: [ :t |
				target betaAngle: t ].
			(newAnimation value: oldShape innerRadius value: newShape innerRadius) onStepDo: [ :t |
				target innerRadius: t ].
			(newAnimation value: oldShape externalRadius value: newShape externalRadius) onStepDo: [ :t |
				target externalRadius: t.
				canvas zoomToFit ];
			yourself
		]
	].

	sb := RSSunburstBuilder new.
	sb
		container: canvas;
		sliceColor: [ :shape | shape model color ].
	sb sliceShape border: (RSBorder new color: Color black).
	canvas addShape: (label := RSLabel new
		isFixed: true;
		yourself).

	newData := [ :class |
		| lastShapes newShapes oshape |
		lastShapes := canvas shapes copy.
		sb explore: class using: aLeafName.
		sb build.
		sb shapes @ RSPopup.

		interaction := RSSunburstFadeInteraction new builder: sb.
		sb shapes
			when: RSMouseEnter do: [ :evt |
				| path |
				path := (interaction pathFor: evt shape) reverse.
				path := path last model fullPath.
				label
					text: path;
					signalUpdate.
				label position: label extent / 2 ]
			for: self;
			when: RSMouseLeave do: [ :evt | label text: '' ]
			for: self.
		sb shapes @ interaction.

		label text: class name.
		newShapes := sb shapes.
		first := newShapes first.
		first
			when: RSMouseClick
			do: [ :evt |
				| cls |
				cls := evt shape model srcNode.
				cls = Object ifFalse: [ newData value: cls ] ]
			for: self.
		(newShapes allButFirst reject: #isSLeaf)
			when: RSMouseClick
			do: [ :evt | newData value: evt shape model ]
			for: self.

		newShapes size < lastShapes size
			ifTrue: [
				newShapes do: [ :new |
					| old |
					old := lastShapes shapeFromModel: new model.
					old ifNotNil: [
						old remove.
						interpolate value: old value: new value: new
					] ].

				oshape := (lastShapes shapeFromModel: class) ifNil: [ RSPieSlice new ] ifNotNil: [ lastShapes shapeFromModel: class ].
				lastShapes do: [ :old |
					| new |
					new := RSPieSlice new.
					(oshape notNil and: [oshape betaAngle < old betaAngle]) ifTrue: [
						new
							alphaAngle: 360;
							betaAngle: 360 ].
					old depth = 1 ifTrue: [
						new
							alphaAngle: 0;
							betaAngle: 360 ].
					(interpolate value: old value: new value: old)
						when: RSAnimationLoopEvent
						do: [ old remove ]
						for: self ] ]
			ifFalse: [
				oshape := lastShapes isEmpty
					ifTrue: [ RSPieSlice new ]
					ifFalse: [
						(newShapes shapeFromModel: lastShapes first model)
							ifNil: [ RSPieSlice new ]
							ifNotNil: [ :shape | shape ] ].

				newShapes do: [ :new |
					| old |
					old := lastShapes shapeFromModel: new model.
					old ifNil: [
						old := RSPieSlice new.
						(oshape notNil and: [oshape betaAngle < new betaAngle]) ifTrue: [
							old
								alphaAngle: 360;
								betaAngle: 360 ]
						ifFalse: [
							old
								alphaAngle: 0;
								betaAngle: 0 ] ].
					new depth = 1 ifTrue: [
						old
							alphaAngle: 0;
							betaAngle: 360 ].
					old remove.
					interpolate value: old value: new value: new ] ].
	].

	canvas
		when: RSExtentChangedEvent
		do: [
			label position:
				canvas extent x / 2 @ (canvas extent y - label height) ]
		for: self.
		
"	legend := (self legend ) asShape.
	sb canvas add: legend.
	legend translateTo: sb canvas extent x + legend extent x @ (0 - sb canvas extent y)."

	newData value: aTree.

	^ canvas

]

{ #category : 'creation' }
Design >> SunburstFor: aProject withLeafs: leafsName [ 
	| sb interaction label legend |
	
	sb := RSSunburstBuilder new.
	sb sliceShape withBorder.
	sb explore: aProject using: leafsName.
	sb build.
	sb canvas @ RSCanvasController.

	interaction := RSSunburstFadeInteraction new builder: sb.

	label := RSLabel new.
	label text: ''.
	label isFixed: true.

	sb shapes
		when: RSMouseEnter do: [ :evt | 
			| path |
			path := (interaction pathFor: evt shape) reverse.
			path := String streamContents: [ :s |
				path do: [ :node | s << node model name asString ]
				     separatedBy: [ s << '/' ] ].
			label
				text: path;
				signalUpdate.
			label position: label extent / 2
		]
		for: self;
		when: RSMouseLeave do: [ :evt | label text: '' ] for: self.

	sb shapes do: [ :shape |
		shape color: shape model color.
	].

	sb shapes @ interaction.
	sb canvas add: label.
	legend := self legend asShape.
	sb canvas add: legend.
	legend translateTo: (sb canvas extent x + (legend extent x) @ (0 - sb canvas extent y)).
	^ sb

]

{ #category : 'max depth control' }
Design >> SunburstFor: aProject withLeafs: leafsName maxDepth: maxDepth [
	| "sb" interaction firstTree label legend |
	
	firstTree := self limitedDepthCopy: aProject maxDepth: maxDepth. 
	
	sunBuilder := RSSunburstBuilder new.
	sunBuilder sliceShape withBorder.
	sunBuilder explore: firstTree using: leafsName.
	sunBuilder build.
	sunBuilder canvas @ RSCanvasController.

	interaction := RSSunburstFadeInteraction new builder: sunBuilder.

	label := RSLabel new.
	label text: ''.
	label isFixed: true.
	
		sunBuilder shapes
		when: RSMouseEnter do: [ :evt |
			| path |
			path := (interaction pathFor: evt shape) reverse.
			path :=  path last model fullPath.
			label
				text: path;
				signalUpdate.
			label position: label extent / 2 ]
		for: self;
		when: RSMouseLeave do: [ :evt | label text: '' ] for: self.
		sunBuilder shapes @ interaction.

	sunBuilder shapes do: [ :shape |
		shape color: shape model color.
	].

	sunBuilder shapes 
		when: RSMouseClick do: [:evt | 
				| clickedNode newTree newSB retrieveNode|
				clickedNode := evt shape model.

				retrieveNode := self retrieveNode: clickedNode name fromTree: aProject . 
				newTree := self limitedDepthCopy: retrieveNode maxDepth: maxDepth.
				newSB := self SunburstFor: newTree withLeafs: #subFoldersOrFile maxDepth: maxDepth withBase: aProject.
				self updateCanvasWith: newSB. 
        ] for: self.

	legend := (self legend ) asShape.
	sunBuilder canvas add: legend.
	sunBuilder canvas add: label.
	legend translateTo: sunBuilder canvas extent x + legend extent x @ (0 - sunBuilder canvas extent y).

    "Optionnel : Ajouter un bouton retour si nécessaire"
    "backButton := RSBox new.
    backButton label: '← Root'; 
    position: (10 @ 10); 
    action: [
        Design new SunburstFor: originalRoot withLeafs: leafsName maxDepth: maxDepth
    ].
    sb canvas add: backButton."
	^ sunBuilder 

]

{ #category : 'max depth control' }
Design >> SunburstFor: aProject withLeafs: leafsName maxDepth: maxDepth withBase: baseProject [
	| "sb" interaction label legend |
	
	sunBuilder sliceShape withBorder.
	sunBuilder explore: aProject using: leafsName.
	sunBuilder build.
	sunBuilder canvas @ RSCanvasController.

	interaction := RSSunburstFadeInteraction new builder: sunBuilder.

	label := RSLabel new.
	label text: 'root'.
	label isFixed: true.

	sunBuilder shapes
		when: RSMouseEnter do: [ :evt |
			| path |
			path := (interaction pathFor: evt shape) reverse.
			path :=  path last model fullPath.
			label
				text: path;
				signalUpdate.
			label position: label extent / 2 ]
		for: self;
		when: RSMouseLeave do: [ :evt | label text: '' ] for: self.
	sunBuilder shapes @ interaction.

	sunBuilder shapes do: [ :shape |
		shape color: shape model color.
	].

	sunBuilder shapes when: RSMouseClick do: [:evt |
		| clickedNode  retrieveNode newTree "window" newSB |
		clickedNode := evt shape model.
		"clickedNode isLeaf ifFalse: [ "  
		retrieveNode := self retrieveNode: clickedNode name fromTree: baseProject.
		newTree := self limitedDepthCopy: retrieveNode maxDepth: maxDepth.
		newSB := self SunburstFor: newTree withLeafs: #subFoldersOrFile maxDepth: maxDepth withBase: baseProject.
		self updateCanvasWith: newSB.
		] for: self.

	legend := (self legend ) asShape.
	sunBuilder canvas add: legend.
	sunBuilder canvas add: label.
	legend translateTo: sunBuilder canvas extent x + legend extent x @ (0 - sunBuilder canvas extent y).

    ^ sunBuilder 

]

{ #category : 'copying' }
Design >> copyNode: node depth: depth maxDepth: maxDepth [
	| clone childs|
	clone := TreeNode new
		name: node name;
		fullPath: node fullPath;
		changed: node changed;
		color: node color;
		changedBy: node changedBy;
		isLeaf: node isLeaf;
		yourself.

	(depth < maxDepth and: [node subFoldersOrFile notEmpty]) ifTrue: [
		childs := (node subFoldersOrFile
					collect: [:child |
					self copyNode: child depth: depth + 1 maxDepth: maxDepth]).
		clone subFoldersOrFile: childs.
	].

	^ clone
]

{ #category : 'accessing' }
Design >> legend [
	| b |
	b := RSLegend new.
	b
		text: 'Changed' withBoxColor: (Color r: 1.0 g: 0.2 b: 0.2);
		text: 'Not Changed' withBoxColor: (Color r: 0.8 g: 0.8 b: 0.8);
		text: 'Unknow' withBoxColor: (Color r: 0.8 g: 1.0 b: 0.8).
	b legendDo: [ :l |
		l
			withBorder;
			padding: 20 ].
	b layout horizontal gapSize: 30.
	^ b

]

{ #category : 'max depth control' }
Design >> limitedDepthCopy: aNode maxDepth: maxDepth [
	"Return a copy of aNode limited to maxDepth levels."
	^ self copyNode: aNode depth: 1 maxDepth: maxDepth
]

{ #category : 'max depth control' }
Design >> retrieveNode: aName fromTree: aTree [

	aTree name = aName ifTrue: [ ^aTree ].
	
	aTree subFoldersOrFile do: [ :aNode |
		| result |
		result := self retrieveNode: aName fromTree: aNode.
		result ifNotNil: [ ^ result ] ].
	^nil
]

{ #category : 'accessing' }
Design >> sunBuilder [
	^sunBuilder
]

{ #category : 'creation' }
Design >> sunBuilder: aBuilder [
	sunBuilder := aBuilder
]

{ #category : 'max depth control' }
Design >> updateCanvas: sb With: aSunburstBuilder [
	sb canvas clear.
	sb canvas add: aSunburstBuilder asShape.
	sb canvas signalUpdate.
	sb canvas changed.


]

{ #category : 'max depth control' }
Design >> updateCanvasWith: aSunburstBuilder [
	sunBuilder canvas clear.
	sunBuilder canvas add: aSunburstBuilder asShape.
	sunBuilder canvas signalUpdate.
	sunBuilder canvas changed.


]
