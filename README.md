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

![demoHeatMapSimpleAnonyme](https://github.com/user-attachments/assets/cbb94c86-2e1c-411b-ae47-034ddaa4deb9)

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

![demoHeatMapInsiderAnonyme](https://github.com/user-attachments/assets/4b54f204-3917-4cdf-94c3-142896a6402e)

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

![demoHeatMapDynamicAnonyme](https://github.com/user-attachments/assets/aa9b48ba-a583-46b2-8966-4b08071fcb6e)

## Contribution

Feel free to contribute. Please fork the repository and create a pull request with a detailed description of your changes.  
You can also help by fixing open issues if there are any.

Thank you!

