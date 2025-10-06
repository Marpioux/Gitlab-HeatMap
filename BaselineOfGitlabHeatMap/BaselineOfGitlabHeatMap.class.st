Class {
	#name : 'BaselineOfGitlabHeatMap',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGitlabHeatMap',
	#package : 'BaselineOfGitlabHeatMap'
}

{ #category : 'baselines' }
BaselineOfGitlabHeatMap >> baseline: spec [

	<baseline>
	spec for: #common do: [
		self defineDependencies: spec.
		self definePackages: spec.
		self defineGroups: spec ]
]

{ #category : 'baselines' }
BaselineOfGitlabHeatMap >> defineDependencies: spec [
		
	spec
    baseline: 'GitLabHealth'
    with: [ spec repository: 'github://moosetechnology/GitProjectHealth:1.x.x/src' ]
]

{ #category : 'baselines' }
BaselineOfGitlabHeatMap >> defineGroups: spec [
]

{ #category : 'baselines' }
BaselineOfGitlabHeatMap >> definePackages: spec [

	spec package: 'Gitlab-Sunburst-Explorer' with: [ spec requires: #('GitLabHealth') ].
]
