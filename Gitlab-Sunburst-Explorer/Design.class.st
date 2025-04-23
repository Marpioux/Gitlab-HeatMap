Class {
	#name : 'Design',
	#superclass : 'Object',
	#category : 'Gitlab-Sunburst-Explorer',
	#package : 'Gitlab-Sunburst-Explorer'
}

{ #category : 'as yet unclassified' }
Design >> SunburstFor: aProject withLeafs: leafsName [ 
	| sb interaction label |
	
	sb := RSSunburstBuilder new.
	sb sliceShape withBorder.
	sb explore: aProject using: leafsName.
	sb build.
	sb canvas @ RSCanvasController.

	interaction := RSSunburstFadeInteraction new builder: sb.

	label := RSLabel new.
	label text: 'fooo'.
	label isFixed: true.

	sb shapes
		when: RSMouseEnter do: [ :evt | 
			| path |
			path := (interaction pathFor: evt shape) reverse.
			path := String streamContents: [ :s |
				path do: [ :node | s << node model name asString ]
				     separatedBy: [ s << '>>' ] ].
			label
				text: path;
				signalUpdate.
			label position: label extent / 2
		]
		for: self;
		when: RSMouseLeave do: [ :evt | label text: '' ] for: self.

	sb shapes do: [ :shape |
		shape color: (self chooseColor: shape).
	].

	sb shapes @ interaction.
	sb canvas add: label.

	^ sb

]

{ #category : 'as yet unclassified' }
Design >> checkDate: aString [
| dateObject today thirtyDaysAgo |
dateObject := aString asDateAndTime.

today := Date today.
thirtyDaysAgo := today addDays: -30.

^ (dateObject >= thirtyDaysAgo) and: (dateObject <= today)

]

{ #category : 'services' }
Design >> chooseColor: aShape [
		| changed |
		changed := aShape model changed.
		changed ifNil: [
			^ (Color r: 0.8 g: 1.0 b: 0.8) 
		] ifNotNil: [ 
			(self checkDate: changed)
				ifTrue: [ ^(Color r: 1.0 g: 0.8 b: 0.8) ]
				ifFalse: [ ^ (Color r: 0.8 g: 0.85 b: 1.0) ]
		].

]
