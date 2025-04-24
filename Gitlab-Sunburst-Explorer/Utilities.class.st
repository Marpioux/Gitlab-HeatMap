Class {
	#name : 'Utilities',
	#superclass : 'Object',
	#instVars : [
		'subFolder',
		'type',
		'glhImporter',
		'project',
		'branch',
		'glApi',
		'dateBlame'
	],
	#classInstVars : [
		'root'
	],
	#category : 'Gitlab-Sunburst-Explorer',
	#package : 'Gitlab-Sunburst-Explorer'
}

{ #category : 'accessing' }
Utilities >> branch [
	^branch
]

{ #category : 'accessing' }
Utilities >> branch: anObject [
	branch := anObject.
]

{ #category : 'creation' }
Utilities >> buildTreeFrom: paths [
	| root pathSet |
	root := TreeNode new.
	root name: 'root'; fullPath: '/'; changed: nil; color: nil.

	pathSet := paths asSet.

	paths do: [:path |
		| parts current currentPath |
		parts := path substrings: '/'.
		current := root.
		currentPath := ''.

		1 to: parts size do: [:index |
			| part next currentIsFile changedValue nodeColor |
			part := parts at: index.
			currentPath := currentPath isEmpty
				ifTrue: [part]
				ifFalse: [currentPath , '/' , part].

			currentIsFile := (pathSet includes: currentPath) and: [
				(pathSet anySatisfy: [:p | p ~= currentPath and: [p beginsWith: currentPath , '/']]) not
				].

			changedValue := currentIsFile
				ifTrue: [self getDateLastBlame: currentPath]
				ifFalse: [nil].
			
			changedValue ifNil: [ nodeColor := (Color r: 0.8 g: 1.0 b: 0.8) ] ifNotNil: [  
			nodeColor := currentIsFile
				ifTrue: [(self checkDate: changedValue)
					ifTrue: [Color r: 1.0 g: 0.2 b: 0.2]
					ifFalse: [Color r: 0.8 g: 0.8 b: 0.8]]
				ifFalse: [nil]. 
				].

			next := current subFoldersOrFile
				detect: [:child | child name = part]
					ifNone: [
						TreeNode new
							name: part;
							fullPath: currentPath;
							changed: changedValue;
							color: nodeColor;
							yourself
							].

			(current subFoldersOrFile includes: next) ifFalse: [
				current subFoldersOrFile add: next
			].

		current := next.
		].
	].

	root := self computeAverageColor: root.
	^ root

]

{ #category : 'services' }
Utilities >> checkDate: aString [
	| dateObject today daysAgo |
	dateObject := aString asDateAndTime.

	today := Date today.
	dateBlame ifNotNil: [ daysAgo := today addDays: (dateBlame) ] ifNil: [ daysAgo := today addDays: -30 ].

	^ (dateObject >= daysAgo) and: (dateObject <= today)
]

{ #category : 'services' }
Utilities >> chooseColor: aShape [

	| changed |
	self
		deprecated: 'Use computeAverageColor: instead of current one'
		on: '24 April 2025'
		in:
		'Pharo-12.0.0+SNAPSHOT.build.1570.sha.3dafb8a476dfe88afa5aa6bf7b148beb9c11003f (64 Bit)'.
	changed := aShape model changed.
	changed ifNil: [ ^ Color r: 0.8 g: 1.0 b: 0.8 ] ifNotNil: [
		(self checkDate: changed)
			ifTrue: [ ^ Color r: 1.0 g: 0.8 b: 0.8 ]
			ifFalse: [ ^ Color r: 0.8 g: 0.85 b: 1.0 ] ]
]

{ #category : 'services' }
Utilities >> computeAverageColor: root [
	| totalRed totalGreen totalBlue count |
	
	totalRed := 0.
	totalGreen := 0.
	totalBlue := 0.
	count := 0.

	root subFoldersOrFile do: [:child |
		self computeAverageColor: child.
		(child color) ifNotNil: [
			totalRed := totalRed + (child color) red.
			totalGreen := totalGreen + (child color) green.
			totalBlue := totalBlue + (child color) blue.
			count := count + 1.
		]
	].

	count > 0 ifTrue: [
		root color: (Color
			r: totalRed / (count)
			g: totalGreen / (count)
			b: totalBlue / (count))
		].

	^ root
]

{ #category : 'accessing' }
Utilities >> dateBlame [
	^dateBlame 
]

{ #category : 'accessing' }
Utilities >> dateBlame: anObject [
	dateBlame := anObject 
]

{ #category : 'services' }
Utilities >> getDateLastBlame: aFilePath [
	| blame |
	blame := NeoJSONReader fromString: (
		glApi repositories getBlameOf: aFilePath 
		inRef: branch 
		ofProject: project id
	).

	blame isEmpty ifTrue: [ ^ nil ].

	(blame isKindOf: Dictionary) ifTrue: [
		(blame includesKey: 'message') ifTrue: [ ^ nil ].
	].

	(blame first isKindOf: Dictionary) ifTrue: [
		^ ((blame first) at: 'commit') at: 'authored_date'
	].

	^ nil

]

{ #category : 'accessing' }
Utilities >> glApi [
	^glApi 
]

{ #category : 'accessing' }
Utilities >> glApi: anObject [
	glApi:= anObject
]

{ #category : 'accessing' }
Utilities >> glhImporter [ 
	^glhImporter
]

{ #category : 'accessing' }
Utilities >> glhImporter: anObject [
	glhImporter:=anObject
]

{ #category : 'accessing' }
Utilities >> project [
	^project
]

{ #category : 'accessing' }
Utilities >> project: anObject [
	project := anObject
]

{ #category : 'services' }
Utilities >> retrieveFiles [
	|selectedBranch files|
	selectedBranch := ( project repository branches detect: [ :b  | b name = branch] ) .
	glhImporter  importFilesOfBranch: selectedBranch .
	files := (selectedBranch allToScope: GLHFile) asOrderedCollection .
	^files collect: #path .

]
