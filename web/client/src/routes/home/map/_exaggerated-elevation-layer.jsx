// https://developers.arcgis.com/javascript/latest/visualization/3d-visualization/terrain-rendering/
import BaseElevationLayer from '@arcgis/core/layers/BaseElevationLayer'
import ElevationLayer from '@arcgis/core/layers/ElevationLayer'

const ExaggeratedElevationLayer = BaseElevationLayer.createSubclass({
  properties: {
    exaggeration: null,
  },

  load: function () {
    this._elevation = new ElevationLayer({
      url: 'https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/TopoBathy3D/ImageServer',
    })
    this.addResolvingPromise(this._elevation.load())
  },

  fetchTile: function (level, row, col, options) {
    return this._elevation.fetchTile(level, row, col, options).then(
      function (data) {
        var exaggeration = this.exaggeration
        for (var i = 0; i < data.values.length; i++) {
          data.values[i] = data.values[i] * exaggeration
        }
        return data
      }.bind(this)
    )
  },
})

export default ExaggeratedElevationLayer
