## Installation

```smalltalk
Metacello new
  githubUser: 'Marpioux' project: 'Gitlab-HeatMap' commitish: 'main' path: 'src';
  baseline: 'GitlabHeatMap';
  onConflict: [ :ex | ex useIncoming ];
  onUpgrade: [ :ex | ex useIncoming ];
  onDowngrade: [ :ex | ex useLoaded ];
  load
```


## Example 

```smalltalk
glphApi := GitlabApi new 
  privateToken: #'<gitlab-token>';
  hostUrl: '<api-url-gitlab>';
  output: 'json';
  yourself.
	
model := GLHModel new.

modelImporter := GitlabModelImporter new
  repoApi: glphApi;
  glhModel: model; 
  withFiles: false;
  withCommitsSince: 0 day;
  withCommitDiffs: true.
	
nodes := Utilities new
  project: (modelImporter importProject: <project-id>);
  branch: '<branch-name>';
  dateBlame: -60; "Optional — if not set explicitly, defaults to -30 days"
  glApi: glphApi;
  glhImporter: modelImporter;
  yourself.
			
files := nodes retrieveFiles.
nodesTree := nodes buildTreeFrom: files .

sb := Design new.
sbCanva := sb SunburstFor: nodesTree withLeafs: #subFoldersOrFile.
sbCanva canvas
```
