import ComboBox from '../../../../../../components/combo-box'
import Tooltip from '@mui/material/Tooltip'

const SelectLocale = () => {
  return (
    <Tooltip title="Select locale" placement="left">
      <ComboBox
        label="Locale"
        options={[
          { label: 'The Shawshank Redemption', year: 1994 },
          { label: 'The Godfather', year: 1972 },
          { label: 'The Godfather: Part II', year: 1974 },
        ]}
      />
    </Tooltip>
  )
}

export default SelectLocale
