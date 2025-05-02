Class {
	#name : 'TreeNode',
	#superclass : 'Object',
	#instVars : [
		'name',
		'subFoldersOrFile',
		'changed',
		'fullPath',
		'color',
		'changedBy',
		'isLeaf',
		'srcNode'
	],
	#category : 'Gitlab-Sunburst-Explorer',
	#package : 'Gitlab-Sunburst-Explorer'
}

{ #category : 'updating' }
TreeNode >> changed [
    ^ changed.
]

{ #category : 'updating' }
TreeNode >> changed: anObject [
    changed := anObject.
]

{ #category : 'accessing' }
TreeNode >> changedBy [
	^changedBy 
]

{ #category : 'accessing' }
TreeNode >> changedBy: aName [
	changedBy := aName
]

{ #category : 'accessing' }
TreeNode >> color [
	^color
]

{ #category : 'accessing' }
TreeNode >> color: anObject [
	color := anObject.
]

{ #category : 'accessing' }
TreeNode >> fullPath [
    ^ fullPath.
]

{ #category : 'as yet unclassified' }
TreeNode >> fullPath: aFilePath [
	fullPath := aFilePath 
]

{ #category : 'accessing' }
TreeNode >> isLeaf [ 
	^ isLeaf
]

{ #category : 'accessing' }
TreeNode >> isLeaf: aBoolean [
	isLeaf := aBoolean.
]

{ #category : 'accessing' }
TreeNode >> name [
    ^name
]

{ #category : 'accessing' }
TreeNode >> name: aName [
    name := aName.
]

{ #category : 'accessing' }
TreeNode >> srcNode [
	^srcNode
]

{ #category : 'accessing' }
TreeNode >> srcNode: aNode [
	srcNode := aNode
]

{ #category : 'accessing' }
TreeNode >> subFoldersOrFile [
    ^ subFoldersOrFile ifNil: [subFoldersOrFile := OrderedCollection new].
]

{ #category : 'accessing' }
TreeNode >> subFoldersOrFile: aCollection [
	subFoldersOrFile := aCollection
]
