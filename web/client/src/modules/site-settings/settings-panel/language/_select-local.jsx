import { useContext, memo } from 'react'
import { context as siteSettingsContext } from '../../_provider'
import ComboBox from '../../../../components/combo-box'
import { Linear as Loading } from '../../../../components/loading'
import Tooltip from '@mui/material/Tooltip'
import { gql, useQuery } from '@apollo/client'
import Box from '@mui/material/Box'

const SelectLocale = ({ updateSetting, language, LANGUAGES }) => {
  const { error, loading, data } = useQuery(
    gql`
      query locales($languages: [Language!]) {
        locales(languages: $languages) {
          id
          name
          code
          language
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
        sx={theme => ({
          width: '100%',
          marginTop: theme.spacing(2),
          [theme.breakpoints.up('sm')]: {
            display: 'block',
            width: 400,
          },
        })}
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
          <Box component="li" sx={{ '& > img': { marginRight: 2, flexShrink: 0 } }} {...props}>
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
}

const Locales = memo(
  props => {
    const { error, loading, data } = useQuery(
      gql`
        query languageLocales($name: String!) {
          __type(name: $name) {
            enumValues {
              name
            }
          }
        }
      `,
      {
        variables: {
          name: 'Language',
        },
      }
    )

    if (loading) {
      return (
        <Loading
          sx={{
            width: '100%',
            marginTop: theme => theme.spacing(2),
          }}
        />
      )
    }

    if (error) {
      throw error
    }

    return <SelectLocale LANGUAGES={data.__type.enumValues.map(({ name }) => name)} {...props} />
  },
  () => false // Needed for now - otherwise the dropdown has incorrect state
)

export default () => {
  const { updateSetting, language } = useContext(siteSettingsContext)

  return <Locales updateSetting={updateSetting} language={language} />
}
