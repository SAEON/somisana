import { useContext, memo } from 'react'
import { ctx as siteSettingsContext } from '../../_provider'
import ComboBox from '../../../../components/combo-box'
import Loading from '../../../../components/loading'
import Tooltip from '@mui/material/Tooltip'
import { gql, useQuery } from '@apollo/client'
import Box from '@mui/material/Box'

const SelectLocale = memo(
  ({ updateSetting, locale }) => {
    const { error, loading, data } = useQuery(
      gql`
        query locales {
          locales {
            id
            ... on Locale {
              locale
              language
            }
          }
        }
      `
    )

    if (loading) {
      return (
        <Loading
          sx={{
            width: '100%',
            mt: theme => theme.spacing(2),
          }}
        />
      )
    }

    if (error) {
      throw error
    }

    return (
      <Tooltip title="Select locale" placement="left">
        <ComboBox
          getOptionLabel={option => option.language}
          label="Locale"
          autoHighlight
          value={data.locales.find(option => option.locale === locale)}
          onChange={(e, option) => updateSetting({ locale: option.locale })}
          options={data.locales}
          renderOption={(props, option) => (
            <Box component="li" sx={{ '& > img': { mr: 2, flexShrink: 0 } }} {...props}>
              <img
                loading="lazy"
                width="20"
                src={`https://flagcdn.com/w20/${option.locale.split('_')[1].toLowerCase()}.png`}
                srcSet={`https://flagcdn.com/w40/${option.locale
                  .split('_')[1]
                  .toLowerCase()}.png 2x`}
                alt=""
              />
              {option.language} ({option.locale})
            </Box>
          )}
        />
      </Tooltip>
    )
  },
  () => false
)

export default () => {
  const { updateSetting, locale } = useContext(siteSettingsContext)

  return <SelectLocale updateSetting={updateSetting} locale={locale} />
}
