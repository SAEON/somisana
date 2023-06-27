import { updateValidationRules } from '../../../../server/mongo/index.js'

export default async () => {
  console.info('Updating validation rules...')
  await updateValidationRules()
}
