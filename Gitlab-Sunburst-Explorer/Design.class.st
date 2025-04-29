Class {
	#name : 'Design',
	#superclass : 'Object',
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

{ #category : 'as yet unclassified' }
Design >> SunburstFor: aProject withLeafs: leafsName maxDepth: maxDepth [
    | sb interaction label legend limitedTree originalRoot backButton |
    
    originalRoot := aProject.
    limitedTree := self limitedDepthCopy: aProject maxDepth: maxDepth.  

    sb := RSSunburstBuilder new.
    sb sliceShape withBorder.
    sb explore: limitedTree using: leafsName.
    sb build.
    sb canvas @ RSCanvasController.

    label := RSLabel new.
    label text: ''; isFixed: true.

    interaction := RSSunburstFadeInteraction new builder: sb.
    sb shapes 
        when: RSMouseEnter do: [:evt | 
            | path |
            path := (interaction pathFor: evt shape) reverse.
            path := String streamContents: [:s |
                path do: [:node | s << node model name asString] separatedBy: [s << '/']
            ].
            label text: path; signalUpdate.
            label position: label extent / 2
        ] for: self;

        when: RSMouseLeave do: [:evt | label text: '' ] for: self.

    sb shapes do: [:shape | shape color: shape model color].

    sb shapes 
        when: RSMouseClick do: [:evt | 
            | clickedNode newTree newSB |
            clickedNode := evt shape model.

            "Créer une copie temporaire du nœud cliqué à la profondeur maxDepth"
            newTree := self limitedDepthCopy: clickedNode maxDepth: maxDepth.

            newSB := Design new SunburstFor: newTree withLeafs: #subFoldersOrFile maxDepth: maxDepth.
            sb canvas clear.
            sb canvas add: newSB asShape.
            sb canvas.
        ] for: self.

	legend := (self legend ) asShape.
    sb canvas add: legend.
    legend translateTo: sb canvas extent x + legend extent x @ (0 - sb canvas extent y).

    "Optionnel : Ajouter un bouton retour si nécessaire"
    "backButton := RSBox new.
    backButton label: '← Root'; 
    position: (10 @ 10); 
    action: [
        Design new SunburstFor: originalRoot withLeafs: leafsName maxDepth: maxDepth
    ].
    sb canvas add: backButton."

    ^ sb

]

{ #category : 'copying' }
Design >> copyNode: node depth: depth maxDepth: maxDepth [
	| clone |
	clone := TreeNode new
		name: node name;
		fullPath: node fullPath;
		changed: node changed;
		color: node color;
		changedBy: node changedBy;
		yourself.

	(depth < maxDepth and: [node subFoldersOrFile notEmpty]) ifTrue: [
		clone subFoldersOrFile:
			(node subFoldersOrFile
				collect: [:child |
					self copyNode: child depth: depth + 1 maxDepth: maxDepth])
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

{ #category : 'as yet unclassified' }
Design >> limitedDepthCopy: aNode maxDepth: maxDepth [
	"Return a copy of aNode limited to maxDepth levels."
	^ self copyNode: aNode depth: 1 maxDepth: maxDepth
]
