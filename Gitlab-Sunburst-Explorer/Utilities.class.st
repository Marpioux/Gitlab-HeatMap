Class {
	#name : 'Utilities',
	#superclass : 'Object',
	#instVars : [
		'subFolder',
		'type',
		'glhImporter',
		'project',
		'branch',
		'glApi'
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

{ #category : 'as yet unclassified' }
Utilities >> buildTreeFrom: paths [
    | root |
    root := TreeNode new.
    root
        name: 'root';
        fullPath: '/';
        changed: nil.

    paths do: [:path |
        | parts current currentPath |
        parts := path substrings: '/'.
        current := root.
        currentPath := ''.

        1 to: parts size do: [:index |
            | part next isLast isFile changedValue |
            part := parts at: index.
            currentPath := currentPath isEmpty
                ifTrue: [part]
                ifFalse: [currentPath , '/' , part].

            isLast := index = parts size.
            isFile := isLast and: [part includes: $.].

            changedValue := isFile
                ifTrue: [self getDateLastBlame: currentPath]
                ifFalse: [nil].

            next := current subFoldersOrFile
                detect: [:child | child name = part]
                ifNone: [
                    TreeNode new
                        name: part;
                        fullPath: currentPath;
                        changed: changedValue;
                        yourself
                ].

            (current subFoldersOrFile includes: next) ifFalse: [
                current subFoldersOrFile add: next
            ].

            current := next.
        ].
    ].

    ^ root

]

{ #category : 'as yet unclassified' }
Utilities >> creationNode [
]

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
Utilities >> retrieveFiles [
	|selectedBranch files|
	selectedBranch := ( project repository branches detect: [ :b  | b name = branch] ) .
	glhImporter  importFilesOfBranch: selectedBranch .
	files := (selectedBranch allToScope: GLHFile) asOrderedCollection .
	^files collect: #path .

]
