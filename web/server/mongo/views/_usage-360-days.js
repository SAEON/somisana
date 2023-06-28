export default {
  name: 'usage360days',
  sourceCollection: 'logs',
  pipeline: [
    {
      $match: {
        createdAt: {
          $gte: new Date(new Date().getTime() - 360 * 24 * 60 * 60 * 1000),
        },
      },
    },
    {
      $group: {
        _id: {
          type: '$type',
          interactionType: '$info.type',
          interactionValue: '$info.value',
          ipAddress: '$clientInfo.ipAddress',
          continent: '$clientInfo.ipInfo.continent',
          country: '$clientInfo.ipInfo.country',
          region: '$clientInfo.ipInfo.region',
          city: '$clientInfo.ipInfo.city',
          isp: '$clientInfo.ipInfo.isp',
          createdAt: {
            $dateToString: {
              format: '%Y-%m-%d',
              date: '$createdAt',
            },
          },
        },
        count: { $sum: 1 },
      },
    },
    {
      $project: {
        _id: 0,
        createdAt: '$_id.createdAt',
        ipAddress: '$_id.ipAddress',
        continent: '$_id.continent',
        country: '$_id.country',
        region: '$_id.region',
        city: '$_id.city',
        isp: '$_id.isp',
        count: '$count',
        type: '$_id.type',
        interactionType: '$_id.interactionType',
        interactionValue: '$_id.interactionValue',
      },
    },
    {
      $sort: {
        createdAt: -1,
        count: -1,
      },
    },
  ],
}
