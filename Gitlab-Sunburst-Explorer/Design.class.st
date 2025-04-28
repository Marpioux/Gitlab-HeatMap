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
