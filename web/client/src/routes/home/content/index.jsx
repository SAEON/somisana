import { forwardRef } from 'react'
import Div from '../../../../../components/div'
import Typography from '@mui/material/Typography'
import Container from '@mui/material/Container'
import { styled } from '@mui/material/styles'

const Paragraph = styled(props => <Typography variant="body1" {...props} />)(({ theme }) => ({
  textAlign: 'justify',
  marginBottom: theme.spacing(2),
}))


export default forwardRef((props, ref) => {
  return null
  return (
    <Div
      ref={ref}
      sx={{
        padding: theme => `${theme.spacing(8)} 0`,
      }}
    >
      <Container>
        <Paragraph>
          Welcome to the SOMISANA Initiative, your gateway to understanding the present and future
          conditions of our oceans. This project, led by the National Research Foundation / South
          African Environmental Observation Network (NRF-SAEON), stands for the Sustainable Ocean
          Modelling Initiative, which embodies our dedication to understanding, protecting, and
          managing the vast waters surrounding the African continent.
        </Paragraph>
        <Paragraph>
          Our website serves as a user-friendly interface to an advanced ocean forecast system. It
          provides access to both short-term and long-term predictions about the conditions of our
          oceans. Thanks to a process known as numerical modelling, we can create a comprehensive
          digital simulation of ocean behaviors. This virtual representation allows us to predict
          everything from temperature changes to marine life movement, helping us anticipate and
          respond to various environmental challenges.
        </Paragraph>
        <Paragraph>
          Working in collaboration with global partners such as the Copernicus Marine Environment
          Monitoring Service (CMEMS), and Deltares, SOMISANA is committed to creating high-quality,
          regionally-focused models. These models are crucial in driving informed decisions and
          sustainable practices to maintain the health of our oceans.
        </Paragraph>
        <Paragraph>
          SOMISANA is also about fostering the future. We aim to inspire and train the next
          generation of South African marine scientists, arming them with the tools and knowledge
          they need to continue this vital work. Through education and hands-on training, we are
          nurturing these future stewards of our oceans.
        </Paragraph>
        <Paragraph>
          In a world where environmental challenges loom large, SOMISANA stands as a beacon of hope.
          Our mission is not just about providing a service; it's about facilitating a greater
          understanding and respect for our oceans, thereby promoting better, more sustainable
          management and conservation practices. Join us on this journey as we navigate towards a
          healthier and more sustainable future for our oceans.
        </Paragraph>
      </Container>
    </Div>
  )
})
