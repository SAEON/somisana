import { forwardRef } from 'react'
import Div from '../../../../../components/div'
import Typography from '@mui/material/Typography'
import Container from '@mui/material/Container'
import { styled } from '@mui/material/styles'

const Paragraph = styled(props => <Typography variant="body1" {...props} />)(({ theme }) => ({
  textAlign: 'justify',
  marginBottom: theme.spacing(2),
}))

/*
Original text with headings


Introduction:
Somisana, short for the Sustainable Ocean Modeling Initiative, is a pioneering effort undertaken by South Africa to enhance its capabilities in the field of numerical modeling. This initiative aims to leverage global advancements, particularly the work done by Copernicus CMEMS (Copernicus Marine Environment Monitoring Service), to develop high-resolution, regional-scale ocean models. By doing so, Somisana seeks to contribute to sustainable ocean management, conservation, and decision-making processes in South Africa.

Expanding Capabilities in Numerical Modeling:
Numerical modeling plays a crucial role in understanding and predicting the complex dynamics of the ocean. It involves creating computer-based models that simulate various aspects of the marine environment, including currents, temperature, salinity, nutrient distribution, and ecosystem interactions. These models help researchers and policymakers gain valuable insights into the functioning of the ocean, assess potential impacts of human activities, and develop effective management strategies.

Somisana recognizes the significance of numerical modeling in addressing marine challenges and aims to expand South Africa's modeling capabilities. By utilizing existing global models, such as those developed by Copernicus CMEMS, Somisana can build upon established frameworks and adapt them to regional contexts. This approach allows South Africa to leverage international expertise, data, and infrastructure while tailoring the models to address specific local concerns and conditions.

Leveraging Copernicus CMEMS:
Copernicus CMEMS, a comprehensive service dedicated to ocean monitoring and forecasting, provides a wealth of data, models, and tools to facilitate sustainable ocean management worldwide. Somisana acknowledges the contributions made by Copernicus CMEMS and seeks to integrate its advancements into South Africa's modeling efforts. By doing so, South Africa can access high-quality data, state-of-the-art modeling techniques, and validated algorithms, enabling more accurate and reliable predictions.

Regional-Scale Modeling:
One of the primary goals of Somisana is to develop high-resolution, regional-scale ocean models. Traditional global-scale models may lack the necessary spatial resolution to capture localized phenomena accurately. Regional models, on the other hand, focus on specific areas, such as coastal regions or marine ecosystems, allowing for a more detailed representation of local processes and interactions.

Through regional-scale modeling, Somisana aims to enhance South Africa's understanding of its coastal and marine environments. This includes analyzing and predicting variables such as coastal circulation patterns, upwelling events, nutrient transport, harmful algal blooms, and the impacts of climate change on these processes. The ability to model these phenomena at a higher resolution will provide valuable insights for decision-makers, resource managers, and conservationists, ultimately contributing to the sustainable use and protection of South Africa's ocean resources.

Benefits and Implications:
The implementation of Somisana carries several benefits and implications for South Africa. By expanding its modeling capabilities, South Africa can improve its ability to predict and manage marine processes and phenomena. This will be instrumental in developing effective conservation strategies, promoting sustainable fisheries practices, mitigating the impacts of climate change, and safeguarding marine biodiversity.

Additionally, the Somisana initiative has the potential to foster collaboration and knowledge exchange between South African researchers, global modeling communities, and institutions like Copernicus CMEMS. By working together, sharing data, and refining modeling techniques, a more comprehensive understanding of the ocean can be achieved, benefitting not only South Africa but the global scientific community as well.

Conclusion:
Somisana, the Sustainable Ocean Modeling Initiative, represents South Africa's commitment to advancing its capabilities in numerical modeling for sustainable ocean management. By leveraging the work done globally, particularly by Copernicus CMEMS, South Africa aims to develop high-resolution, regional-scale models tailored to its unique coastal and marine environments. Through this initiative, South Africa seeks to enhance its understanding of the ocean,

*/

export default forwardRef((props, ref) => {
  return null
  return (
    <Div
      ref={ref}
      sx={{
        padding: theme => `${theme.spacing(8)} 0`,
        backgroundColor: theme => theme.palette.background.paper,
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
