import { useContext, memo } from 'react'
import { ctx as siteSettingsContext } from '../../_provider'
import ComboBox from '../../../../components/combo-box'
import Loading from '../../../../components/loading'
import Tooltip from '@mui/material/Tooltip'
import { gql, useQuery } from '@apollo/client'
import Box from '@mui/material/Box'

const LANGUAGES = ['en']

const SelectLocale = memo(
  ({ updateSetting, language }) => {
    const { error, loading, data } = useQuery(
      gql`
        query locales($languages: [Language!]) {
          locales(languages: $languages) {
            id
            ... on Locale {
              name
              code
              language
            }
          }
        }
      `,
      {
        variables: {
          languages: LANGUAGES,
        },
      }
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
      <Tooltip title="Select language" placement="left">
        <ComboBox
          getOptionLabel={option => option.name}
          label="language"
          autoHighlight
          value={data.locales.find(option => option.language === language)}
          onChange={(e, option) => updateSetting({ language: option.language })}
          options={data.locales}
          renderOption={(props, option) => (
            <Box component="li" sx={{ '& > img': { mr: 2, flexShrink: 0 } }} {...props}>
              <img
                loading="lazy"
                width="20"
                src={`https://flagcdn.com/w20/${option.code.split('_')[1].toLowerCase()}.png`}
                srcSet={`https://flagcdn.com/w40/${option.code.split('_')[1].toLowerCase()}.png 2x`}
                alt=""
              />
              {option.name}
            </Box>
          )}
        />
      </Tooltip>
    )
  },
  () => false
)

export default () => {
  const { updateSetting, language } = useContext(siteSettingsContext)

  return <SelectLocale updateSetting={updateSetting} language={language} />
}
