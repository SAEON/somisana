import { hydrateRoot } from 'react-dom/client'

export default Page => hydrateRoot(document.getElementById('root'), <Page />).render(<Page />)
