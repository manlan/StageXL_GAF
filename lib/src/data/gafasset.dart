part of stagexl_gaf;

class GAFAsset {

  final GAFAssetConfig config;

  final List<GAFTimeline> _timelines = new List<GAFTimeline>();
  final Map<String, GAFTimeline> _timelinesMap = new Map<String, GAFTimeline>();
  final Map<String, GAFTimeline> _timelinesByLinkage = new Map<String, GAFTimeline>();

  num scale = 1.0;
  num csf = 1.0;

  //--------------------------------------------------------------------------

  GAFAsset(this.config) {
    this.scale = config.defaultScale;
    this.csf = config.defaultContentScaleFactor;
  }

  //--------------------------------------------------------------------------

  String get id => config.id;
  List<GAFTimeline> get timelines => _timelines;

  //--------------------------------------------------------------------------

  void addGAFTimeline(GAFTimeline timeline) {
    if (!_timelinesMap.containsKey(timeline.id)) {
      _timelinesMap[timeline.id] = timeline;
      _timelines.add(timeline);
      if (timeline.config.linkage != null) {
        _timelinesByLinkage[timeline.linkage] = timeline;
      }
    } else {
      throw new StateError("Bundle error. More then one timeline use id: '" + timeline.id + "'");
    }
  }

  /// Returns [GAFTimeline] from gaf asset by linkage
  ///
  /// @param linkage linkage in a *.fla file library

  GAFTimeline getGAFTimelineByLinkage(String linkage) {
    return _timelinesByLinkage[linkage];
  }

  /// Returns <code>GAFTimeline</code> from gaf asset by ID
  ///
  /// @param id internal timeline id

  GAFTimeline getGAFTimelineByID(String id) {
    return _timelinesMap[id];
  }

  //--------------------------------------------------------------------------

  IGAFTexture _getCustomRegion(String linkage, [num scale, num csf]) {

    scale = scale ?? this.scale;
    csf = csf ?? this.csf;

    IGAFTexture gafTexture = null;

    for(var atlasScale in config.allTextureAtlases) {
      if (atlasScale.scale == scale) {
        for(var atlasCSF in atlasScale.allContentScaleFactors) {
          if (atlasCSF.csf == csf) {
            var element = atlasCSF.elements.getElementByLinkage(linkage);
            if (element != null) {
              var texture = atlasCSF.atlas._getTextureByIDAndAtlasID(element.id, element.atlasID);
              var pivotMatrix = element.pivotMatrix;
              if (element.scale9Grid != null) {
                gafTexture = new GAFScale9Texture(id, texture, pivotMatrix, element.scale9Grid);
              } else {
                gafTexture = new GAFTexture(id, texture, pivotMatrix);
              }
            }

            break;
          }
        }
        break;
      }
    }

    return gafTexture;
  }

  /** @ */
  num _getValidScale(num value) {
    int index = MathUtility.getItemIndex(this.config.scaleValues, value);
    if (index != -1) {
      return this.config.scaleValues[index];
    }
    return null;
  }

  /** @ */
  bool _hasCSF(num value) {
    return MathUtility.getItemIndex(config.csfValues, value) >= 0;
  }

}