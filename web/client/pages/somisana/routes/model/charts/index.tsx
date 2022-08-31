import ReactECharts from 'echarts-for-react'
import makeEchartsTheme from '../../../../../modules/echarts/themes/default'
import useTheme from '@mui/material/styles/useTheme'

export default () => {
  const theme = useTheme()

  return (
    <ReactECharts
      option={{
        xAxis: {
          type: 'category',
          data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        },
        yAxis: {
          type: 'value',
        },
        series: [
          {
            data: [150, 230, 224, 218, 135, 147, 260],
            type: 'line',
          },
        ],
      }}
      notMerge={true}
      lazyUpdate={true}
      theme={makeEchartsTheme(
        9,
        { color: theme.palette.primary.main, pos: 0 },
        { color: theme.palette.grey[200], pos: 0.3 },
        { color: theme.palette.grey[400], pos: 0.6 },
        { color: theme.palette.secondary.main, pos: 1 }
      )}
    />
  )
}
