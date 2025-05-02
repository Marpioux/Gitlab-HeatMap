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

"OR"

sb := Design new.
sbCanva := sb SunburstFor: nodesTree withLeafs: #subFoldersOrFile maxDepth: 2.
sbCanva canvas

"OR"

sb:= Design new.
sbCanva := sb DynamicSunburstFor: nodesTree withLeafs: #subFoldersOrFile.
sbCanva canvas.


"See explanation for the severals sunbursts in README.md"
```

## HeatMap Visualizations Explained

This document describes three types of heatmaps used to visualize your gitlab project structure and last blame using sunburst diagrams. Each version offers a distinct way to explore the contents of a codebase.


### 1. Simple Heatmap

This version displays a basic sunburst view of the project.

**Create it using:**

```smalltalk
sb := Design new.
sbCanva := sb SunburstFor: nodesTree withLeafs: #subFoldersOrFile.
sbCanva canvas
```

**Features**:

+ Click on any node to view details about that folder or file.

+ Each file node includes:
    + ``name``
    + ``changed`` (last modification date from Git blame)
    + ``fullpath``
    + ``color`` (visual indicator, e.g., based on changes)
    + ``changedBy`` (author of last change)
    + ``srcNode`` (parent package)

**Example:**

![demoGitHeatMapSimple](https://github.com/user-attachments/assets/6fc76828-507f-4d74-835a-d586b40f6435)

### 2. Insider Heatmap
This version is designed for easier navigation in large projects by limiting the visible depth.

**Create it using:**

```smalltalk
sb := Design new.
sbCanva := sb SunburstFor: nodesTree withLeafs: #subFoldersOrFile maxDepth: 2.
sbCanva canvas
```
**Features**:

+ The maxDepth parameter sets how many layers are initially shown.
+ Clicking on a node zooms into that section and regenerates the sunburst with the clicked node as the new root.
+ This allows focused exploration without overwhelming the view.
+ Same informations for files and folders as Simple Heatmap

**Example:**

![demoGitHeatMapInsider](https://github.com/user-attachments/assets/423289c3-8079-42fa-9dfe-23888366cdde)

### 3. Dynamic Heatmap
This is the most scalable version and is suitable for large codebases.

**Create it using:**

```smalltalk
sb:= Design new.
sbCanva := sb DynamicSunburstFor: nodesTree withLeafs: #subFoldersOrFile.
sbCanva canvas.
```

**Features**:

+ Begins as a simple sunburst.
+ Clicking a node sets it as the new root, allowing for detailed exploration.
+ To return to the previous view, click the center node.
+ Same informations for files and folders as Simple Heatmap

**Example:**

![demoGitHeatMapDynamic](https://github.com/user-attachments/assets/251690e4-6f76-4ecd-b4e2-17c95860f668)

## Contribution

Feel free to contribute. Please fork the repository and create a pull request with a detailed description of your changes.  
You can also help by fixing open issues if there are any.

Thank you!

