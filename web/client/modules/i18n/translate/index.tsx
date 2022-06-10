import { useContext, useState } from 'react'
import { ctx as i18nContext } from '../index'
import Box from '@mui/material/Box'
import { Translate } from '../../../components/icons'
import Form from './form'
import Icon from '@mui/material/Icon'
import Tooltip from '@mui/material/Tooltip'

export default ({ contentId }) => {
  const [open, setOpen] = useState(false)
  const { t, language } = useContext(i18nContext)
  const { text, missing } = t(contentId, language)

  if (missing) {
    return (
      <>
        <Tooltip placement="top-end" title="Click to translate!">
          <Box
            onClick={() => setOpen(!open)}
            sx={{
              position: 'relative',
              outline: theme => `thin dotted ${theme.palette.success.main}`,
              cursor: 'pointer',
              transition: theme => theme.transitions.create(['background-color']),
              '&:hover': {
                backgroundColor: theme => theme.palette.grey[100],
              },
            }}
          >
            <Icon
              component={Translate}
              sx={{
                width: '0.65em',
                height: '0.65em',
                position: 'absolute',
                right: 0,
                top: 0,
              }}
            />
            {text}
          </Box>
        </Tooltip>
        <Form from={text} open={open} setOpen={setOpen} />
      </>
    )
  }

  return text
}
