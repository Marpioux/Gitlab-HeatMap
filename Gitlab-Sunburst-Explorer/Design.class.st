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
			path := String streamContents: [ :s |
					        path
						        do: [ :node | s << node model name asString ]
						        separatedBy: [ s << '/' ] ].
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
	label text: ''.
	label isFixed: true.

	sunBuilder shapes
		when: RSMouseEnter do: [ :evt |
			| path |
			path := (interaction pathFor: evt shape) reverse.
			path := String streamContents: [ :s |
					        path
						        do: [ :node | s << node model name asString ]
						        separatedBy: [ s << '/' ] ].
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
		retrieveNode := self retrieveNode: clickedNode name fromTree: baseProject.
		newTree := self limitedDepthCopy: retrieveNode maxDepth: maxDepth.
		newSB := self SunburstFor: newTree withLeafs: #subFoldersOrFile maxDepth: maxDepth withBase: aProject.
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

{ #category : 'as yet unclassified' }
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
